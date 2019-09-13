function [ energyElectrons , psiF, densityF ] = selfConsistentSolver( electronCounter,energyOld, densityInit,psiInit, x, y, distmin, epsilon, q, r, c, dx, dy, Vg, Vgp, hbar, m, wellNumber, wellX, wellY, invPosDiff, compParams)
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
        qDensityAll=zeros(r*c,1);
        Ex=zeros(r*c);
        for k=1:electronCounter
            if j~=k
                %Hartree
                qDensityAll=qDensityAll+qDensity(:,k);
                
                %Exchange
%                 Ex1=psiInit(:,k)*psiInit(:,k)'*((-hbar^2/(2*m))*(dx+dy)+q*Vg);%Kinetic and gate potential
%                 Ex2=((-hbar^2/(2*m))*(dx+dy)+q*Vg)*psiInit(:,k)*psiInit(:,k)';%Kinetic and gate potential
%                 Vf=q*psiInit(:,k)*psiInit(:,k)'.*invPosDiff./(4*pi*epsilon);%Fock
%                 interaction energy commmented on 2017/06/28
%                 Ex=Ex+q*Vf;
%                 Ex=Ex+Ex1+Ex2+q*Vf;
            end
        end
        
        %Hartree
        qDensityMat=ones(r*c)*diag(qDensityAll);
        Vh=1*diag(sum(qDensityMat.*invPosDiff./(4*pi*epsilon),2));%.5 added on 2017/07/06
        VhPlot=denPlot(diag(Vh),r,c);
        
        %Exchange
        ExPlot=denPlot(diag(Ex),r,c);%Doesnt capture off diagonal terms but oh well
        
        figure(5+electronCounter)
        subplot(electronCounter,3,3*j-2)
        h=surf(compParams.vXsmall, compParams.vYsmall,q*VhPlot);
        set(h, 'EdgeColor', 'none')
        title(['Hartree Potential on electron ' num2str(j)]);
        subplot(electronCounter,3,3*j-1)
        h=surf(compParams.vXsmall, compParams.vYsmall,ExPlot);
        set(h, 'EdgeColor', 'none')
        title(['Exchange Potential (only local terms) on electron ' num2str(j)]);
        subplot(electronCounter,3,3*j)
        h=surf(compParams.vXsmall, compParams.vYsmall,q*VhPlot+q*Vgp+ExPlot);
        set(h, 'EdgeColor', 'none')
        title(['Total Potential on electron ' num2str(j)]);
%         dummywait=input('dummywait');
    
        H=-(hbar^2/(2*m))*(dx+dy)+q*Vg+q*Vh+Ex;
        
%         opts.v0=psiInit(:,j);
        %switched on 2017/07/05 from eigs to eig
%         [evecTemp,evalMatTemp]=eigs(H,4,'sm',opts);
%         evalTemp=diag(evalMatTemp);
        
%         tic
%         H=gpuArray(H);%faster not on the GPUs
        [evecTemp,evalTemp]=eig(H,'vector');
%         evecTemp=gather(evecTemp);
%         evalMatTemp=gather(evalMatTemp);
%         toc
        
        [evalTemp, order]=sort(evalTemp);
        evecTemp=evecTemp(:,order);
        densityTemp=conj(evecTemp).*evecTemp;
        
        evalTemp=real(evalTemp);%Exchange would give imaginary term

        dPlot1=denPlot(densityTemp(:,1),r,c);
        dPlot2=denPlot(densityTemp(:,2),r,c);
        dPlot3=denPlot(densityTemp(:,3),r,c);
        dPlot4=denPlot(densityTemp(:,4),r,c);

        figure(200+j)
        subplot(2,2,1)
        h=surf(compParams.vXsmall, compParams.vYsmall,dPlot1);
        set(h, 'EdgeColor', 'none')
        title(['First Eigenstate, Energy = ' num2str(evalTemp(1))])

        subplot(2,2,2)
        h=surf(compParams.vXsmall, compParams.vYsmall,dPlot2);
        set(h, 'EdgeColor', 'none')
        title(['Second Eigenstate, Energy = ' num2str(evalTemp(2))])

        subplot(2,2,3)
        h=surf(compParams.vXsmall, compParams.vYsmall,dPlot3);
        set(h, 'EdgeColor', 'none')
        title(['Third Eigenstate, Energy = ' num2str(evalTemp(3))])

        subplot(2,2,4)
        h=surf(compParams.vXsmall, compParams.vYsmall,dPlot4);
        set(h, 'EdgeColor', 'none')
        title(['Fourth Eigenstate, Energy = ' num2str(evalTemp(4))])
        
        psiInit(:,j)=evecTemp(:,1);
        densityInit(:,j)=densityTemp(:,1);
        energyNew=energyNew+evalTemp(1);
        occ=whichWell(evecTemp(:,1),x,y,wellX,wellY);
        occNew=occNew+occ;
    end
    
    if (abs((energyOld-energyNew)/energyNew)<.01)
        display('Difference between iterations within tollerance.')
        if occNew==occOld
            display('Charge state same between iterations.')
            converg=0;
        end
    end
    
    if iterations>100
        converg=0;
        display('Will not converg');
    end
end

psiF=psiInit;
densityF=densityInit;
VHEnergy=0;
VExEnergy=0;
Ewoh=0;

qDensity=q*densityInit;
for j=1:electronCounter
    qDensityAll=zeros(r*c,1);
    Ex=zeros(r*c);
    for k=1:electronCounter
        if j~=k
                %Hartree
                qDensityAll=qDensityAll+qDensity(:,k);
                
                %Exchange
%                 Ex1=psiF(:,k)*psiF(:,k)'*((-hbar^2/(2*m))*(dx+dy)+q*Vg);%Kinetic and gate potential
%                 Ex2=((-hbar^2/(2*m))*(dx+dy)+q*Vg)*psiF(:,k)*psiF(:,k)';%Kinetic and gate potential
%                 Vf=q*psiF(:,k)*psiF(:,k)'.*invPosDiff./(4*pi*epsilon);%Fock
%                 interaction energy  commented on 2017/06/28
%                 Ex=Ex+Ex1+Ex2+q*Vf;
%                 Ex=Ex+q*Vf; %on 2017/06/28
        end
    end
    
        %Hartree
        qDensityMat=ones(r*c)*diag(qDensityAll);%2017/06/29
        Vh=diag(sum(qDensityMat.*invPosDiff./(4*pi*epsilon),2));%2017/06/29
    
    Hwoh=-(hbar^2/(2*m))*(dx+dy)+q*Vg;
    Ewoh=Ewoh+psiF(:,j)'*Hwoh*psiF(:,j);
    VHEnergy=VHEnergy+q*psiF(:,j)'*Vh*psiF(:,j)/2;
    VExEnergy=VExEnergy+real(psiF(:,j)'*Ex*psiF(:,j))/2;%Exchange could give imaginary terms
end

energyElectrons=Ewoh+VHEnergy+VExEnergy;
display(['Inter-electron energy is ' num2str(VHEnergy)])
display(['Total energy is ' num2str(energyElectrons)])
end

