function [ energyElectrons , psiF, densityF ] = selfConsistentSolver( electronCounter,energyOld, densityInit,psiInit, x, y, distmin, epsilon, q, r, c, dx, dy, Vg, Vgp, hbar, m, wellNumber, wellX, wellY, invPosDiff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
converg=1;
iterations=0;
energyNew=energyOld;
occNew=zeros(1,wellNumber);
for j=1:electronCounter
    occ=whichWellDensity( densityInit(:,j), x, y, wellX, wellY );
    occNew=occNew+occ;
end
while converg
    iterations=iterations+1;
    display(['Starting Iteration ' num2str(iterations)])
    energyOld=energyNew;
    energyNew=0;
    occOld=occNew;
    occNew=zeros(1,wellNumber);
%     filledLevelsTemp=filledLevels;
    for j=1:electronCounter
        qDensity=q*densityInit;
        Vh=zeros(r*c);
        VhPlot=zeros(r,c);
        for k=1:electronCounter
            if j~=k
                Vhtemp=den2hartree(qDensity(:,k),x,y,distmin,epsilon);
                VhPlottemp=denPlot(diag(Vhtemp),r,c);
                Vh=Vh+Vhtemp;
                VhPlot=VhPlot+VhPlottemp;
            end
        end

        figure(7)
        subplot(electronCounter,2,2*j-1)
        h=surf(q*VhPlot);
        set(h, 'EdgeColor', 'none')
        title(['Hartree Potential on electron ' num2str(j)]);
        subplot(electronCounter,2,2*j)
        h=surf(q*VhPlot+q*Vgp);
        set(h, 'EdgeColor', 'none')
        title(['Total Potential on electron ' num2str(j)]);
%         dummywait=input('dummywait');
    
        H=-(hbar^2/(2*m))*(dx+dy)+q*Vg+q*Vh;
        
        opts.v0=psiInit(:,j);
        [evecTemp,evalMatTemp]=eigs(H,4,'sm',opts);
%         H=gpuArray(H);
%         [evecTemp,evalMatTemp]=eig(H);
%         evecTemp=gather(evecTemp);
%         evalMatTemp=gather(evalMatTemp);
        
        evalTemp=diag(evalMatTemp);
        [evalTemp, order]=sort(evalTemp);
        evecTemp=evecTemp(:,order);
        densityTemp=conj(evecTemp).*evecTemp;

        dPlot1=denPlot(densityTemp(:,1),r,c);
        dPlot2=denPlot(densityTemp(:,2),r,c);
        dPlot3=denPlot(densityTemp(:,3),r,c);
        dPlot4=denPlot(densityTemp(:,4),r,c);

        figure(200+j)
        subplot(2,2,1)
        h=surf(dPlot1);
        set(h, 'EdgeColor', 'none')
        title(['First Eigenstate, Energy = ' num2str(evalTemp(1))])

        subplot(2,2,2)
        h=surf(dPlot2);
        set(h, 'EdgeColor', 'none')
        title(['Second Eigenstate, Energy = ' num2str(evalTemp(2))])

        subplot(2,2,3)
        h=surf(dPlot3);
        set(h, 'EdgeColor', 'none')
        title(['Third Eigenstate, Energy = ' num2str(evalTemp(3))])

        subplot(2,2,4)
        h=surf(dPlot4);
        set(h, 'EdgeColor', 'none')
        title(['Fourth Eigenstate, Energy = ' num2str(evalTemp(4))])
        
        psiInit(:,j)=evecTemp(:,1);
        densityInit(:,j)=densityTemp(:,1);
        energyNew=energyNew+evalTemp(1);
        occ=whichWell(evecTemp(:,1),x,y,wellX,wellY);
        occNew=occNew+occ;
    end
    
    if (abs((energyOld-energyNew)/energyNew)<.005)
        display('Difference between iterations within tollerance.')
        if occNew==occOld
            display('Charge state same between iterations.')
            converg=0;
        end
    end
end

psiF=psiInit;
densityF=densityInit;
VHEnergy=0;
Ewoh=0;

qDensity=q*densityInit;
for j=1:electronCounter
    Vh=zeros(r*c);
    for k=1:electronCounter
        if j~=k
                Vhtemp=den2hartree(qDensity(:,k),x,y,distmin,epsilon);
                Vh=Vh+Vhtemp;
        end
    end
    Hwoh=-(hbar^2/(2*m))*(dx+dy)+q*Vg;
    Ewoh=Ewoh+psiF(:,j)'*Hwoh*psiF(:,j);
    VHEnergy=VHEnergy+q*psiF(:,j)'*Vh*psiF(:,j);
end

energyElectrons=Ewoh+VHEnergy/2;
display(['Inter-electron energy is ' num2str(VHEnergy/2)])
display(['Total energy is ' num2str(energyElectrons)])
end

