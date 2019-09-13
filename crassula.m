function [  gates, newSaveFile] = crassula(files,compParams,physParams,opts)

if size(files.gateFiles,2)>size(physParams.z0s,2)
    for j=1:size(compParams.rectGrid,2)
        physParams.z0s(1,j)=physParams.z0s(1,1);
    end
end


%Opens the save file to get the structure gates if there is a save file.
%Making gates is computationally expensive.  Any time you are going to run
%the simulation with the same gridding as before, you should use the save
%file.
if isempty(files.saveFile)
    % File conversion

    % dxfExtract takes the DXF file names and returns the data in a form which
    % can be used to compute the potential.  Skips this if there is a saveFile
    % so you should use a saveFile everytime after the first time you open a
    % set of DXF files.
    gates=dxfExtract(files, compParams,physParams);
    
    %Compute the potential at the 2DEG from the gates
    switch opts.gpuSwitch
        case 0
            tic
            [gates,compParams]=voltageCompGPU(gates,files,compParams);
            gpuTime=toc;
            display(['GPU time was ' num2str(gpuTime)])
            
            tic
            parpool
            poolTime=toc;
            display(['Parallel pool start time is ' poolTime '.  This is a sunk time that only happens the first time'])
            
            tic
            [gates,compParams]=voltageComp(gates,files,compParams);
            parTime=toc;
            display(['Parallel time was ' num2str(parTime)])
            if gpuTime<parTime
                disp('You should use the GPU.  Set gpuSwtich=1.')
            else
                disp('You should use the parallel for loop.  Set gpuSwtich=2.')
            end
        case 1
            [gates,compParams]=voltageCompGPU(gates,files,compParams);
        case 2
            [gates,compParams]=voltageComp(gates,files,compParams);
    end
    
else %saves a lot of time
    load(files.saveFile)
end

%Get the names of all the gates
gateNames=sort(fieldnames(gates));

%Plot the rectangular breakdown of the gates

if opts.plotRects
    figure(100); clf; hold on
    for j=1:size(gateNames,1)
        
        tempField=getfield(gates,gateNames{j});
        
        [xs, ys]=plotForm(tempField.rects);
        sizex=size(xs);
        for i=1:sizex(2)
            fill(xs(:,i),ys(:,i),1)
        end
    end
end

gateVPlotter( gates, opts )

voltageMap=voltPlot2DEG( gates, compParams,opts );

densityPlot2DEG( voltageMap, compParams,physParams );

continueTuning=1;
while continueTuning
    [gates, continueTuning]=gateTune(gates,compParams,opts);
    voltageMap=voltPlot2DEG( gates, compParams,opts );
    densityPlot2DEG( voltageMap, compParams,physParams );
end

newSaveFile=saveGates(gates,compParams);

V=voltPlot2DEG( gates, compParams, opts );

% %Self consistent calculation of electron wave functions taking into account
% %the Hartree potential from inter electron interactions.
[ gates, compParams] = chargeGroundStateFinder( gates, compParams, physParams, opts, V);

chargeStabilityDiagramer(gates, compParams, physParams, opts)






if 0 %bringing stuff below this online still

findQParams=input('Solve for singlet-triplet qubit parameters?');
if findQParams
    display('Click first gate to sweep.')
    [dPoly1, polyn1]=polyClickerDotMap( xpsfine, ypsfine, xminfine, yminfine, polysfine );
    
    v1min=input('Minimum voltage on this gate?');
    v1max=input('Maximum voltage on this gate?');
    
    display('Click second gate to sweep.')
    [dPoly2, polyn2]=polyClickerDotMap( xpsfine, ypsfine, xminfine, yminfine, polysfine );
    
    v2min=input('Minimum voltage on this gate?');
    v2max=input('Maximum voltage on this gate?');
    vNStep=input('Number of gate voltage steps?');
    
    [dvPlotfine1, dvCompfine1, dxmin1, dymin1]=voltMapper(dPoly1, xpsfine,ypsfine);
    vFineG1=vCompGPU( vXmin, vXmax, vYmin, vYmax, vGridx,vGridy, z0, dvCompfine1 );
    v1BaseVal=polysfine{polyn1,2};
    
    [dvPlotfine2, dvCompfine2, dxmin2, dymin2]=voltMapper(dPoly2, xpsfine,ypsfine);
    vFineG2=vCompGPU( vXmin, vXmax, vYmin, vYmax, vGridx,vGridy, z0, dvCompfine2 );
    v2BaseVal=polysfine{polyn2,2};
    
    polysWoSweptGates=polysfine;
    if polyn1>polyn2
        polysWoSweptGates(polyn1,:)=[];
        polysWoSweptGates(polyn2,:)=[];
    elseif polyn1<polyn2
        polysWoSweptGates(polyn2,:)=[];
        polysWoSweptGates(polyn1,:)=[];
    end
    
    [plotfineWoSG, dvCompfineWoSG, dxminWoSG, dyminWoSG]=voltMapper(polysWoSweptGates, xpsfine,ypsfine);
    vFineWoSG=vCompGPU( vXmin, vXmax, vYmin, vYmax, vGridx,vGridy, z0, dvCompfineWoSG );
    
    vSelectArea=(v1BaseVal+(v1min+v1max)/2)*vFineG1+(v2BaseVal+(v2min+v2max)/2)*vFineG2+vFineWoSG;
    
    display('Please click on the bottom left and upper right corner of the area of interest.')
    figure(12)
    h=pcolor(vSelectArea);
    set(h,'EdgeColor','none');
    [x, y]=ginput(2);
    x=round(x);
    y=round(y);
    xreal=x*vGridx+xminfine;
    yreal=y*vGridy+yminfine;
    vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1),x(2)]):max([x(1),x(2)]));
    wellNumber=input('Number of potential wells?');
    figure(4)
    h=pcolor(vPsiComp);
    set(h, 'EdgeColor', 'none')
    [wellXN, wellYN]=ginput(wellNumber);
    wellX=vGridx*wellXN*10^-6;
    wellY=vGridy*wellYN*10^-6;
    
    leftWellN=input('Left dot number of ST qubit?');
    rightWellN=input('Right dot number of ST qubit?');
    
    [evalFinal, densityFinal, psiFinal, occupFinal] = densitySolver(vPsiComp,vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY);
    

%     figure(4)
%     display('Please click on the bottom left and upper right corner of the area of interest.')
%     [x, y]=ginput(2);
%     x=round(x);
%     y=round(y);
%     xreal=x*vGridx+xminfine;
%     yreal=y*vGridy+yminfine;
%     vPsiCompQubit=vPsiComp(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1),x(2)]):max([x(1),x(2)]));
    
    vPsiCompQubit=vPsiComp;
    wellXQubit=vertcat(wellX(leftWellN),wellX(rightWellN));
    wellYQubit=vertcat(wellY(leftWellN),wellY(rightWellN));
    
    electronPsis=psiFinal{1,end};
    [pointsInSpace, numElectrons]=size(electronPsis);
    
    qubitElectrons=[];
    otherElectrons=[];
    
    [r,c]=size(vPsiComp);
    xpsi=zeros(size(diag(vPsiCompQubit)));
    ypsi=zeros(size(diag(vPsiCompQubit)));
    for j=1:r*c
        ypsi(j)=floor((j-.1)/c)*vGridy*10^-6;
        xpsi(j)=vGridx*(j-floor((j-.1)/c)*c)*10^-6;
    end
    
    for j=1:numElectrons
        specificWellNumber=whichWellNumber(electronPsis(:,j), xpsi, ypsi, wellX, wellY );
        if specificWellNumber==leftWellN
            qubitElectrons=horzcat(qubitElectrons,electronPsis(:,j));
        elseif specificWellNumber==rightWellN
            qubitElectrons=horzcat(qubitElectrons,electronPsis(:,j));
        else
            otherElectrons=horzcat(otherElectrons,electronPsis(:,j));
        end
    end
    
    vFineWoSGClipped=vFineWoSG(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
    vFineG1Clipped=vFineG1(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
    vFineG2Clipped=vFineG2(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
    
%     [ singletEnergy, singletDensity, singletPsi, singletOccup, tripletEnergy, tripletDensity, tripletPsi, tripletOccup, v1Vals, v2Vals ] = qubitParamSolver( v1min, v1max, v2min, v2max, vNStep, vFineG1Clipped, vFineG2Clipped, vFineWoSGClipped, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellXQubit,wellYQubit,x,y,v1BaseVal,v2BaseVal, qubitElectrons, otherElectrons, leftWellN, rightWellN );
        [ singletEnergy, singletDensity, singletPsi, singletOccup, tripletEnergy, tripletDensity, tripletPsi, tripletOccup, v1Vals, v2Vals ] = qubitParamSolver( v1min, v1max, v2min, v2max, vNStep, vFineG1Clipped, vFineG2Clipped, vFineWoSGClipped, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y,v1BaseVal,v2BaseVal, qubitElectrons, otherElectrons, leftWellN, rightWellN );
    
    vVals=vertcat(v1Vals,v2Vals);
    cmag=10^-22;
    tmag=10^-25;
    L11mag=10^0;
    V110mag=10^-2;
    L12mag=10^0;
    V120mag=10^-2;
    L21mag=10^0;
    L22mag=10^0;
        
    c0=2;
    t=1;
    L11=.5;
    V110=(vVals(1,1)+vVals(1,end))/(2*V110mag);
    L12=.5;
    V120=(vVals(2,1)+vVals(2,end))/(2*V120mag);
    L21=.5;
    L22=.5;

%     c0=2;
%     t=1;
%     L11=.5;
%     V110=3.15;
%     L12=.5;
%     V120=7.5;
%     L21=.5;
%     L22=.5;
% 
%     cmag=10^-22;
%     tmag=10^-25;
%     L11mag=10^0;
%     V110mag=10^-2;
%     L12mag=10^0;
%     V120mag=10^-2;
%     L21mag=10^-1;
%     L22mag=10^-1;



    b0=[c0, t, L11, V110, L12, V120, L21, L22];
    mags=[cmag, tmag, L11mag, V110mag, L12mag, V120mag, L21mag, L22mag];

    
%     sing=@(b,v)b(1)*mags(1)-(1/2)*((b(3)*mags(3)*q*(v(1,:)-b(4)*mags(4))+b(5)*mags(5)*q*(v(2,:)-b(6)*mags(6))).^2).^.5+b(7)*mags(7)*q*v(1,:)+b(8)*mags(8)*q*v(2,:);
    sing=@(b,v)b(1)*mags(1)-(1/2)*(4*(b(2)*mags(2)).^2+(b(3)*mags(3)*q*(v(1,:)-b(4)*mags(4))+b(5)*mags(5)*q*(v(2,:)-b(6)*mags(6))).^2).^.5+b(7)*mags(7)*q*v(1,:)+b(8)*mags(8)*q*v(2,:);
    qParamsFit=nlinfit(vVals,singletEnergy,sing,b0);

    qParams=qParamsFit.*mags;
    detuning=qParams(3).*q.*(vVals(1,:)-qParams(4))+qParams(5).*q.*(vVals(2,:)-qParams(6));

    figure(800);hold on
    plot(detuning, singletEnergy,'ob')
    plot(detuning, tripletEnergy,'or')
    plot(detuning, sing(qParamsFit,vVals),'g')

    exchange=tripletEnergy-singletEnergy;
    figure(801)
    plot(detuning,exchange);
end


% Shows the final gate voltages by adding up the initial changes and those
% made after the self consistent calculation.
FinalGV=initAllDvChange;%just to get the size right
for j=1:length(initAllDvChange)
    FinalGV(j)=initAllDvChange(j)+polysfine{j,2};
end
end
end

