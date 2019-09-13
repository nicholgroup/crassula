function [evalFinal, densityFinal, psiFinal, occupFinal] = densitySolverAtPoint(Vgp, compParams, physParams)
%( Vgp,xps,yps,m,hbar,q,EF,epsilon, wellNumber,wellX,wellY )
%UNTITLED3 Summary of this function goes here,
%   Detailed explanation goes here

m=physParams.m;
hbar=physParams.hbar;
q=physParams.q;
EF=physParams.EF;
epsilon=physParams.epsilon;

xps=compParams.vGrid;
yps=compParams.vGrid;

wellNumber=compParams.wellNumber;

unitScale=compParams.unitScale;%converts microns to meters for calculation
wellX=compParams.wellX.*unitScale;
wellY=compParams.wellY.*unitScale;


[r,c]=size(Vgp);
distmin=unitScale*.47*(xps+yps)/2;

dx=d2dx2(xps*unitScale,r,c);
dy=d2dy2(yps*unitScale,r,c);
Vg=vConvDen(Vgp);



% x=zeros(size(diag(Vg)));
% y=zeros(size(diag(Vg)));
% for j=1:r*c
%     y(j)=floor((j-.1)/c)*yps*10^-6;
%     x(j)=xps*(j-floor((j-.1)/c)*c)*10^-6;
% end
x=repmat(compParams.vXsmall,1,length(compParams.vYsmall))'.*unitScale;
y=repelem(compParams.vYsmall,length(compParams.vXsmall))'.*unitScale;

invPosDiff=zeros(length(x));
for j=1:length(x)
    for k=1:length(x)
        if j~=k
            invPosDiff(j,k)=1/((x(j)-x(k))^2+(y(j)-y(k))^2)^.5;
        else
            invPosDiff(j,k)=1/distmin;
        end
    end
end
% posDiff=zeros(length(x));
% for j=1:length(x)
%     for k=1:length(x)
%         if j~=k
%             posDiff(j,k)=((x(j)-x(k))^2+(y(j)-y(k))^2)^.5;
%         else
%             posDiff(j,k)=distmin;
%         end
%     end
% end
% Vf0=(q/(4*pi*epsilon))*1./posDiff;

% H=-(hbar^2/(2*m))*(dx+dy);
H=-(hbar^2/(2*m))*(dx+dy)+q*(Vg);
% H=-(hbar^2/(2*m))*(dx+dy)+Vg;%NEED TO CHANGE FOR VOLTAGE!!!!
% 
%2017/07/05 switched from eigs to eig because eigs misses lowest values
% [eVec,eValmat]=eigs(H,8,'sm');
% eVal=diag(eValmat);
% [eVal, order]=sort(eVal);
% eVec=eVec(:,order);
% density=conj(eVec).*eVec;

[eVec,eVal]=eig(H,'vector');
[eVal,order]=sort(eVal);
eVec=eVec(:,order);
% density=conj(eVec(:,1:8)).*eVec(:,1:8);
density=conj(eVec(:,:)).*eVec(:,:);


% dPlot1=denPlot(density(:,1),r,c);
% dPlot2=denPlot(density(:,2),r,c);
% dPlot3=denPlot(density(:,3),r,c);
% dPlot4=denPlot(density(:,4),r,c);
% dPlot5=denPlot(density(:,5),r,c);
% dPlot6=denPlot(density(:,6),r,c);
% dPlot7=denPlot(density(:,7),r,c);
% dPlot8=denPlot(density(:,8),r,c);

% figure(5)
% subplot(2,3,1)
% h=surf(q*Vgp);
% set(h, 'EdgeColor', 'none')
% title('Potential Energy From Gates')
% 
% figure(6)
% subplot(2,4,1)
% h=surf(dPlot1);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,2)
% h=surf(dPlot2);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,3)
% h=surf(dPlot3);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,4)
% h=surf(dPlot4);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,5)
% h=surf(dPlot5);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,6)
% h=surf(dPlot6);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,7)
% h=surf(dPlot7);
% set(h, 'EdgeColor', 'none')
% 
% subplot(2,4,8)
% h=surf(dPlot8);
% set(h, 'EdgeColor', 'none')

densityWSpinDegen=horzcat(density(:,1:4),density(:,1:4));
eVecWSpinDegen=horzcat(eVec(:,1:4),eVec(:,1:4));
eValWSpinDegen=horzcat(eVal(1:4),eVal(1:4));

% density2=density;
filledLevels=sum(eVal<=EF);
electronCounter=1;
% if (9 > filledLevels) && ( filledLevels > 0)2017/07/05
if filledLevels > 0
%     display('Can fit at least 1 electron')
    belowFermi=1;
    evalFinal=[eVal(1)];
    densityFinal={density(:,1)};
    psiFinal={eVec(:,1)};
    occupF=whichWell(eVec(:,1), x, y, wellX, wellY);
    occupFinal={occupF};
%     display(['Occupation is (' num2str(occupF) ')'])
    electronCounter=electronCounter+1;
    while belowFermi
        occupF=zeros(1,wellNumber);
%         display(['Beginning computation for ' num2str(electronCounter) ' electrons.'])
        energyOld=evalFinal(end)+eValWSpinDegen(electronCounter);
        densityInit=horzcat(densityFinal{1,electronCounter-1},densityWSpinDegen(:,electronCounter));
        psiInit=horzcat(psiFinal{1,electronCounter-1},eVecWSpinDegen(:,electronCounter));
        [ energyElectrons , psiF, densityF ]=selfConsistentSolverAtPoint( electronCounter,energyOld, densityInit,psiInit, x, y, distmin, epsilon, q, r, c, dx, dy, Vg, Vgp, hbar, m, wellNumber, wellX, wellY, invPosDiff);
        eNoCharge=EF+evalFinal(1,electronCounter-1);
        if eNoCharge>energyElectrons
            psiFinal{1,electronCounter}=psiF;
            densityFinal{1,electronCounter}=densityF;
            evalFinal(1,electronCounter)=energyElectrons;
            for j=1:electronCounter
                wellOfElectronj=whichWell(psiF(:,j),x,y,wellX,wellY);
                occupF=occupF+wellOfElectronj;
            end
%             display(['Occupation is (' num2str(occupF) ')'])
            occupFinal{1,electronCounter}=occupF;
%             display(['Can fit at least ' num2str(electronCounter) ' electrons'])
            electronCounter=electronCounter+1;
        else
            belowFermi=0;
%             display(['Last electron is ' num2str(electronCounter-1)])
            display(['Charge configuration is (' num2str(occupFinal{1,end}) ')'])
%             display(['Fermi level is ' num2str(EF)])
%             display([num2str(electronCounter-1) ' electron energy is ' num2str(evalFinal(1,electronCounter-1))])
%             display([num2str(electronCounter) ' electron energy is ' num2str(energyElectrons)])
        end
    end
    eNumber=size(evalFinal);
%     for j=1:eNumber(2)
%         figure(300+j)
%         densityPlot=zeros(r,c);
%         for k=1:j
%             densityPlot=densityPlot+denPlot(densityFinal{1,j}(:,k),r,c);
%         end
%         h=surf(densityPlot);
%         set(h, 'EdgeColor', 'none');
%     end
else
    display('No filled levels')
    evalFinal=[];
    densityFinal={};
    psiFinal={};
    occupFinal={zeros(1,wellNumber)};
    display(['EF = ' num2str(EF)])
    display(['Lowest Energy = ' num2str(eVal(1))])
end

end


