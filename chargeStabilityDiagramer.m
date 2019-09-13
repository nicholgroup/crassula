function [  ] = chargeStabilityDiagramer( gates,compParams,physParams,opts)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

%Get the names of all the gates
gateNames=sort(fieldnames(gates));

    function strtCSD(x,y)
        dotMap=1;
        uiresume(gcbf)
        close(uiFig)
    end
    function nope(x,y)
        dotMap=0;
        uiresume(gcbf)
        close(uiFig)
    end

uiFig=figure(1001);
set(1001,'pos',[300 100 600 200])
g = uicontrol('Position',[100 100 200 40],'String','Compute charge stability diagram',...
    'Callback',@strtCSD);
h = uicontrol('Position',[300 100 200 40],'String','Nope',...
    'Callback',@nope);
uiwait(gcf);

%Sets the default values to the first gate in case the user doesn't change
%that
CSD.firstGate.name=gateNames{1};
tempField=getfield(gates,gateNames{1});
CSD.firstGate.lowerVoltage=tempField.setVoltage;
CSD.firstGate.upperVoltage=tempField.setVoltage;

CSD.secondGate.name=gateNames{2};
tempField=getfield(gates,gateNames{2});
CSD.secondGate.lowerVoltage=tempField.setVoltage;
CSD.secondGate.upperVoltage=tempField.setVoltage;

CSD.voltStep=.001;
CSD.wellNumber=1;

    function firstGate(source,callbackdata)
        %         a = get(source,'string');
        CSD.firstGate.name=source.String{source.Value};
        tempField=getfield(gates,CSD.firstGate.name);
        CSD.firstGate.lowerVoltage=tempField.setVoltage;
        CSD.firstGate.upperVoltage=tempField.setVoltage;
        uiresume(uiFig2)
    end

    function secondGate(source,callbackdata)
        %         a = get(source,'string');
        CSD.secondGate.name=source.String{source.Value};
        tempField=getfield(gates,CSD.secondGate.name);
        CSD.secondGate.lowerVoltage=tempField.setVoltage;
        CSD.secondGate.upperVoltage=tempField.setVoltage;
        uiresume(uiFig2)
    end

    function fgLV(source,callbackdata)
        %         a = get(source,'string');
        CSD.firstGate.lowerVoltage=str2double(source.String);
        uiresume(uiFig2)
    end

    function fgUV(source,callbackdata)
        %         a = get(source,'string');
        CSD.firstGate.upperVoltage=str2double(source.String);
        uiresume(uiFig2)
    end

    function sgLV(source,callbackdata)
        %         a = get(source,'string');
        CSD.secondGate.lowerVoltage=str2double(source.String);
        uiresume(uiFig2)
    end

    function sgUV(source,callbackdata)
        %         a = get(source,'string');
        CSD.secondGate.upperVoltage=str2double(source.String);
        uiresume(uiFig2)
    end

    function voltStepSize(source,callbackdata)
        %         a = get(source,'string');
        CSD.voltStep=str2double(source.String);
        uiresume(uiFig2)
    end

    function numWell(source,callbackdata)
        %         a = get(source,'string');
        CSD.wellNumber=str2double(source.String);
        uiresume(uiFig2)
    end

% 
%     function ready(x,y)
%         uiresume(gcbf)
%     end
    function posClicker(~,~)
        figure(2)
        [xReal, yReal]=ginput(2);
        [~,x]=min(abs(compParams.vXs-xReal),[],2);
        [~,y]=min(abs(compParams.vYs-yReal),[],2);
        vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        compParams.vXsmall=compParams.vXs(min(x):max(x));
        compParams.vYsmall=compParams.vYs(min(y):max(y));
        
        CSD.x=round(x);
        CSD.y=round(y);
    
        
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none')
        if autoWellPos
            figure(4); hold on;
            regMax=imregionalmax(vPsiComp);
            [row, col]=find(regMax);
            [col, ind]=sort(col);
            row=row(ind);
            compParams.wellNumber=length(row);
            compParams.wellX=compParams.vXsmall(col)';
            compParams.wellY=compParams.vYsmall(row)';
        end
        if isfield(compParams,'wellX')
            if isfield(compParams,'wellX')
                figure(4); hold on;
                plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
                for fontCount=1:length(compParams.wellX)
                    text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
                end
            end
        end
        uiresume(uiFig2)
    end

    function simRun(~,~)
%         if compParams.wellNumber==length(compParams.wellX)
%             waitToSim=0;
%         else
%             figure(1005)
%             text(50,50,'You need to "Select well locations".')
%         end
        if isfield(compParams,'wellX')
            if compParams.wellNumber==length(compParams.wellX)
                waitToSim=0;
            else
                figure(1005); clf
                set(1005,'pos',[1000 600 300 100])
                uicontrol('Style','text',...
                	'Position',[50 25 200 40],...
                    'String','You need to "Select well locations".')
            end
        else
            figure(1005); clf
            set(1005,'pos',[1000 600 300 100])
            uicontrol('Style','text',...
                'Position',[50 25 200 40],...
                'String','You need to "Select well locations".')
        end
        uiresume(uiFig2)
    end

    function makeFig(~,~)
        plotStabDiag=0;
        uiresume(uiFig4)
    end

    function LEfun(source,~)
        a = get(source,'string');
        vX=str2double(a);
        [~,vXgridNumNew]=min(abs(compParams.vXs-vX),[],2);
        [~,vXgridNumOld]=min(abs(compParams.vXs-compParams.vXsmall(end)),[],2);
        x=[vXgridNumOld,vXgridNumNew];
        [~,y]=min(abs(compParams.vYs-[compParams.vYsmall(1);compParams.vYsmall(end)]),[],2);
        compParams.vXsmall=compParams.vXs(min(x):max(x));
        vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        
        CSD.x=round(x);
        CSD.y=round(y);
        
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none')
        if autoWellPos
            figure(4); hold on;
            regMax=imregionalmax(vPsiComp);
            [row, col]=find(regMax);
            [col, ind]=sort(col);
            row=row(ind);
            compParams.wellNumber=length(row);
            compParams.wellX=compParams.vXsmall(col)';
            compParams.wellY=compParams.vYsmall(row)';
        end
        if isfield(compParams,'wellX')
            if isfield(compParams,'wellX')
                figure(4); hold on;
                plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
                for fontCount=1:length(compParams.wellX)
                    text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
                end
            end
        end
        uiresume(uiFig2)
    end

    function REfun(source,~)
        a = get(source,'string');
        vX=str2double(a);
        [~,vXgridNumNew]=min(abs(compParams.vXs-vX),[],2);
        [~,vXgridNumOld]=min(abs(compParams.vXs-compParams.vXsmall(1)),[],2);
        x=[vXgridNumOld,vXgridNumNew];
        [~,y]=min(abs(compParams.vYs-[compParams.vYsmall(1);compParams.vYsmall(end)]),[],2);
        compParams.vXsmall=compParams.vXs(min(x):max(x));
        vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        
        CSD.x=round(x);
        CSD.y=round(y);
        
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none')
        if autoWellPos
            figure(4); hold on;
            regMax=imregionalmax(vPsiComp);
            [row, col]=find(regMax);
            [col, ind]=sort(col);
            row=row(ind);
            compParams.wellNumber=length(row);
            compParams.wellX=compParams.vXsmall(col)';
            compParams.wellY=compParams.vYsmall(row)';
        end
        if isfield(compParams,'wellX')
            if isfield(compParams,'wellX')
                figure(4); hold on;
                plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
                for fontCount=1:length(compParams.wellX)
                    text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
                end
            end
        end
        uiresume(uiFig2)
    end

    function BEfun(source,~)%fix
        a = get(source,'string');
        vY=str2double(a);
        [~,vYgridNumNew]=min(abs(compParams.vYs-vY),[],2);
        [~,vYgridNumOld]=min(abs(compParams.vYs-compParams.vYsmall(end)),[],2);
        y=[vYgridNumOld,vYgridNumNew];
        [~,x]=min(abs(compParams.vXs-[compParams.vXsmall(1);compParams.vXsmall(end)]),[],2);
        compParams.vYsmall=compParams.vYs(min(y):max(y));
        vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        
        CSD.x=round(x);
        CSD.y=round(y);
        
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none')
        if autoWellPos
            figure(4); hold on;
            regMax=imregionalmax(vPsiComp);
            [row, col]=find(regMax);
            [col, ind]=sort(col);
            row=row(ind);
            compParams.wellNumber=length(row);
            compParams.wellX=compParams.vXsmall(col)';
            compParams.wellY=compParams.vYsmall(row)';
        end
        if isfield(compParams,'wellX')
            if isfield(compParams,'wellX')
                figure(4); hold on;
                plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
                for fontCount=1:length(compParams.wellX)
                    text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
                end
            end
        end
        uiresume(uiFig2)
    end
    function TEfun(source,~)
        a = get(source,'string');
        vY=str2double(a);
        [~,vYgridNumNew]=min(abs(compParams.vYs-vY),[],2);
        [~,vYgridNumOld]=min(abs(compParams.vYs-compParams.vYsmall(1)),[],2);
        y=[vYgridNumOld,vYgridNumNew];
        [~,x]=min(abs(compParams.vXs-[compParams.vXsmall(1);compParams.vXsmall(end)]),[],2);
        compParams.vYsmall=compParams.vYs(min(y):max(y));
        vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        
        CSD.x=round(x);
        CSD.y=round(y);
        
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none')
        if autoWellPos
            figure(4); hold on;
            regMax=imregionalmax(vPsiComp);
            [row, col]=find(regMax);
            [col, ind]=sort(col);
            row=row(ind);
            compParams.wellNumber=length(row);
            compParams.wellX=compParams.vXsmall(col)';
            compParams.wellY=compParams.vYsmall(row)';
        end
        if isfield(compParams,'wellX')
            if isfield(compParams,'wellX')
                figure(4); hold on;
                plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
                for fontCount=1:length(compParams.wellX)
                    text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
                end
            end
        end
        uiresume(uiFig2)
    end
    function Wellfun(source,~)
        autoWellPos=0;
        a = get(source,'string');
        wellNum=str2double(a);
        compParams.wellNumber=wellNum;
        CSD.wellNumber=wellNum;
        if isfield(compParams,'wellX')
            if length(compParams.wellX)>compParams.wellNumber
                compParams.wellX=compParams.wellX(1:compParams.wellNumber);
                compParams.wellY=compParams.wellY(1:compParams.wellNumber);
            end
        end
        uiresume(uiFig2)
    end
    function wellPosFun(~,~)
        autoWellPos=0;
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none'); hold on;
        wellX=[];
        wellY=[];
        for j=1:compParams.wellNumber
            [wellXtemp,wellYtemp]=ginput(1);
            wellX=[wellX; wellXtemp];
            wellY=[wellY; wellYtemp];
            plot(wellXtemp,wellYtemp,'k+','MarkerSize',20,'LineWidth',5)
            text(wellXtemp,wellYtemp,['    ' num2str(j)],'Color','k', 'FontSize',12)
        end
%         [wellX, wellY]=ginput(compParams.wellNumber);
        %         compParams.wellX=compParams.vGrid*wellXN*10^-6;
        %         compParams.wellY=compParams.vGrid*wellYN*10^-6;
        compParams.wellX=wellX;
        compParams.wellY=wellY;
        %I think the CSD.wellX and CSD.wellY are unused now.
        CSD.wellX=compParams.wellX-compParams.vXsmall(1);
        CSD.wellY=compParams.wellY-compParams.vYsmall(1);
%         plot(wellX,wellY,'k+','MarkerSize',20,'LineWidth',5)
        uiresume(uiFig2)
    end

    function firstDot(source,callbackdata)
        %         a = get(source,'string');
        if strcmp(source.String{source.Value},'None')
            CSD.firstDot=0;
        else
            CSD.firstDot=str2double(source.String{source.Value});
        end
        uiresume(uiFig4)
    end
    function secondDot(source,callbackdata)
        %         a = get(source,'string');
        if strcmp(source.String{source.Value},'None')
            CSD.secondDot=0;
        else
            CSD.secondDot=str2double(source.String{source.Value});
        end
        uiresume(uiFig4)
    end
    function thirdDot(source,callbackdata)
        %         a = get(source,'string');
        if strcmp(source.String{source.Value},'None')
            CSD.thirdDot=0;
        else
            CSD.thirdDot=str2double(source.String{source.Value});
        end
        uiresume(uiFig4)
    end

if ~isfield(compParams,'vXsmall')
    compParams.vXsmall=compParams.vXs;
end
if ~isfield(compParams,'vYsmall')
    compParams.vYsmall=compParams.vYs;
end
if ~isfield(compParams,'wellNumber')
    compParams.wellNumber=1;
end
if ~exist('vPsiComp','var')
    vSelectArea=voltPlot2DEG( gates, compParams,opts );
    %[~,x]=min(abs(compParams.vXs-[compParams.vXsmall(1);compParams.vXsmall(end)]),[],2);
    %[~,y]=min(abs(compParams.vYs-[compParams.vYsmall(1);compParams.vYsmall(end)]),[],2);
    
    %JMN 2017/11/20
    [~,x]=min([abs(compParams.vXs-compParams.vXsmall(1)) ;abs(compParams.vXs-compParams.vXsmall(end))],[],2);
    [~,y]=min([abs(compParams.vYs-compParams.vYsmall(1)) ;abs(compParams.vYs-compParams.vYsmall(end))],[],2);
    
    vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
end
% JMN 2017/11/2-
%[~,x]=min(abs(compParams.vXs-[compParams.vXsmall(1);compParams.vXsmall(end)]),[],2);
%[~,y]=min(abs(compParams.vYs-[compParams.vYsmall(1);compParams.vYsmall(end)]),[],2);

[~,x]=min([abs(compParams.vXs-compParams.vXsmall(1)) ;abs(compParams.vXs-compParams.vXsmall(end))],[],2);
[~,y]=min([abs(compParams.vYs-compParams.vYsmall(1)) ;abs(compParams.vYs-compParams.vYsmall(end))],[],2);


CSD.x=round(x);
CSD.y=round(y);

figure(4); clf
h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
set(h, 'EdgeColor', 'none')
if isfield(compParams,'wellX')
    if isfield(compParams,'wellX')
        figure(4); hold on;
        plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
        for fontCount=1:length(compParams.wellX)
            text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
        end
    end
else
    vSelectArea=voltPlot2DEG( gates, compParams,opts );
    %     maxMatrix=max(vSelectArea(:));
    %     [row,col] = find(vSelectArea==maxMatrix);
    %     compParams.wellX=compParams.vXs(col);
    %     compParams.wellY=compParams.vYs(row);
    regMax=imregionalmax(vPsiComp);
    [row, col]=find(regMax);
    [col, ind]=sort(col);
    row=row(ind);
    compParams.wellNumber=length(row);
    compParams.wellX=compParams.vXsmall(col)';
    compParams.wellY=compParams.vYsmall(row)';
    figure(4); hold on;
    plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
    for fontCount=1:length(compParams.wellX)
        text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
    end
end

autoWellPos=1;

if dotMap
    waitToSim=1;
    while waitToSim
        %Make sure the upper is really greater than the lower
        if CSD.firstGate.lowerVoltage>CSD.firstGate.upperVoltage
            tempStore=CSD.firstGate.lowerVoltage;
            CSD.firstGate.lowerVoltage=CSD.firstGate.upperVoltage;
            CSD.firstGate.upperVoltage=tempStore;
        end
        
        if CSD.secondGate.lowerVoltage>CSD.secondGate.upperVoltage
            tempStore=CSD.secondGate.lowerVoltage;
            CSD.secondGate.lowerVoltage=CSD.secondGate.upperVoltage;
            CSD.secondGate.upperVoltage=tempStore;
        end
        
        gatesTemp=gates;
        tempField=getfield(gatesTemp,CSD.firstGate.name);
        tempField.setVoltage=(CSD.firstGate.upperVoltage+CSD.firstGate.lowerVoltage)/2;
        gatesTemp=setfield(gatesTemp,CSD.firstGate.name,tempField);
        tempField=getfield(gatesTemp,CSD.secondGate.name);
        tempField.setVoltage=(CSD.secondGate.upperVoltage+CSD.secondGate.lowerVoltage)/2;
        gatesTemp=setfield(gatesTemp,CSD.secondGate.name,tempField);
        
        vSelectArea=voltPlot2DEG( gatesTemp, compParams,opts );
        
        gateNames1={};
        gateNames1{1}=CSD.firstGate.name;
        for gdum=1:length(gateNames)
            if ~strcmp(gateNames{gdum},CSD.firstGate.name)
                gateNames1{end+1}=gateNames{gdum};
            end
        end
        
        gateNames2={};
        gateNames2{1}=CSD.secondGate.name;
        for gdum=1:length(gateNames)
            if ~strcmp(gateNames{gdum},CSD.secondGate.name)
                gateNames2{end+1}=gateNames{gdum};
            end
        end
        
        uiFig2=figure(1003); clf
        set(1003,'pos',[300 100 900 400])
        
        uicontrol('Style','text',...
            'Position',[0 100 150 40],...
            'String','First Gate');
        
        fGate = uicontrol('Style', 'popup',...
            'String', gateNames1,...
            'Position', [150 100 200 40],...
            'Callback', @firstGate);
        
        uicontrol('Style','edit',...
            'Position',[150 60 150 40],...
            'String',num2str(CSD.firstGate.lowerVoltage),...
            'Callback',@fgLV);
        uicontrol('Style','text',...
            'Position',[0 60 150 20],...
            'String','Lower voltage bound');
        
        uicontrol('Style','edit',...
            'Position',[150 20 150 40],...
            'String',num2str(CSD.firstGate.upperVoltage),...
            'Callback',@fgUV);
        uicontrol('Style','text',...
            'Position',[0 20 150 20],...
            'String','Upper voltage bound');
        
        
        uicontrol('Style','text',...
            'Position',[300 100 200 40],...
            'String','Second Gate');
        sGate = uicontrol('Style', 'popup',...
            'String', gateNames2,...
            'Position', [450 100 150 40],...
            'Callback', @secondGate);
        uicontrol('Style','edit',...
            'Position',[450 60 150 40],...
            'String',num2str(CSD.secondGate.lowerVoltage),...
            'Callback',@sgLV);
        uicontrol('Style','text',...
            'Position',[300 60 150 20],...
            'String','Lower voltage bound');
        
        uicontrol('Style','edit',...
            'Position',[450 20 150 40],...
            'String',num2str(CSD.secondGate.upperVoltage),...
            'Callback',@sgUV);
        uicontrol('Style','text',...
            'Position',[300 20 150 20],...
            'String','Upper voltage bound');
        
        
        
        uicontrol('Style','edit',...
            'Position',[750 100 150 40],...
            'String',num2str(CSD.voltStep),...
            'Callback',@voltStepSize);
        uicontrol('Style','text',...
            'Position',[600 100 150 20],...
            'String','Voltage step size');
        
        %     uicontrol('Style','edit',...
        %         'Position',[750 60 150 40],...
        %         'String','1',...
        %         'Callback',@numWell);
        %     uicontrol('Style','text',...
        %         'Position',[600 60 150 20],...
        %         'String','Number of quantum dots');
        
%         g = uicontrol('Position',[750 20 150 40],'String','Ready!',...
%             'Callback',@ready);
        
        LEtext=uicontrol('Style','text',...
            'Position',[50 275 50 40],...
            'String','Lower x coord');
        uicontrol('Style','edit',...
            'Position',[100 275 75 40],...
            'String',num2str(compParams.vXsmall(1)),...
            'Callback',@LEfun);
        
        REtext=uicontrol('Style','text',...
            'Position',[50 225 50 40],...
            'String','Upper x coord');
        uicontrol('Style','edit',...
            'Position',[100 225 75 40],...
            'String',num2str(compParams.vXsmall(end)),...
            'Callback',@REfun);
        
        BEtext=uicontrol('Style','text',...
            'Position',[200 275 50 40],...
            'String','Lower y coord');
        uicontrol('Style','edit',...
            'Position',[250 275 75 40],...
            'String',num2str(compParams.vYsmall(1)),...
            'Callback',@BEfun);
        
        TEtext=uicontrol('Style','text',...
            'Position',[200 225 50 40],...
            'String','Upper y coord');
        uicontrol('Style','edit',...
            'Position',[250 225 75 40],...
            'String',num2str(compParams.vYsmall(end)),...
            'Callback',@TEfun);
        
        clickPos = uicontrol('Position',[50 325 200 40],'String','Click to get position (Fig 4)',...
            'Callback',@posClicker);
        runSim = uicontrol('Position',[600 325 200 40],'String','Run simulation',...
            'Callback',@simRun);
        
        Welltext=uicontrol('Style','text',...
            'Position',[350 325 50 40],...
            'String','Number of dots');
        uicontrol('Style','edit',...
            'Position',[400 325 75 40],...
            'String',num2str(compParams.wellNumber),...
            'Callback',@Wellfun);
        findWellPos = uicontrol('Position',[350 275 200 40],'String','Select well locations (Fig 2)',...
            'Callback',@wellPosFun);
        
        figure(4); clf;
        h=pcolor(compParams.vXsmall, compParams.vYsmall,vPsiComp);
        set(h, 'EdgeColor', 'none')
        if isfield(compParams,'wellX')
            if isfield(compParams,'wellX')
                figure(4); hold on;
                plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
                for fontCount=1:length(compParams.wellX)
                    text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
                end
            end
        end
        
        uiwait(uiFig2);
    end
    
    
    
    
    
%     display('Please click on the bottom left and upper right corner of the area of interest.')
% 
%     [xReal, yReal]=ginput(2);
%     [~,x]=min(abs(compParams.vXs-xReal),[],2);
%     [~,y]=min(abs(compParams.vYs-yReal),[],2);
%     CSD.x=round(CSD.x);
%     CSD.y=round(CSD.y);
%     vPsiComp=vSelectArea(min([CSD.y(1),CSD.y(2)]):max([CSD.y(1),CSD.y(2)]),min([CSD.x(1),CSD.x(2)]):max([CSD.x(1),CSD.x(2)]));
%     compParams.vXsmall=compParams.vXs(min(x):max(x));
%     compParams.vYsmall=compParams.vYs(min(y):max(y));
    
%     figure(4); clf
%     h=pcolor(vPsiComp);
%     set(h, 'EdgeColor', 'none')
%     display('Please click on the centers of the dots.')
%     [wellXN, wellYN]=ginput(CSD.wellNumber);
%     CSD.wellX=compParams.vGrid*wellXN*10^-6;
%     CSD.wellY=compParams.vGrid*wellYN*10^-6;
    
    [ chargeMap,rowVals,colVals ]=dotChargeMap(gates,CSD, compParams, physParams);
    [ wellOccupPlot ] = plottableChargeMap(chargeMap );
    
    CSD.firstDot=0;
    CSD.secondDot=0;
    CSD.thirdDot=0;
    
    plotStabDiag=1;
    dotList={'None'};
    for dotty=1:compParams.wellNumber
        dotList{end+1}=num2str(dotty);
    end
    
    while plotStabDiag
        
        if CSD.firstDot==0
            dotList1={'None'};
        else
            dotList1={num2str(CSD.firstDot)};
        end
        for gdum=1:length(dotList)
            if ~strcmp(dotList{gdum},dotList1{1})
                dotList1{end+1}=dotList{gdum};
            end
        end
        
        if CSD.secondDot==0
            dotList2={'None'};
        else
            dotList2={num2str(CSD.secondDot)};
        end
        for gdum=1:length(dotList)
            if ~strcmp(dotList{gdum},dotList2{1})
                dotList2{end+1}=dotList{gdum};
            end
        end
        
        if CSD.thirdDot==0
            dotList3={'None'};
        else
            dotList3={num2str(CSD.thirdDot)};
        end
        for gdum=1:length(dotList)
            if ~strcmp(dotList{gdum},dotList3{1})
                dotList3{end+1}=dotList{gdum};
            end
        end
        
        
        uiFig4=figure(1004); clf
        set(1004,'pos',[300 100 900 400])
        
        fDot = uicontrol('Style', 'popup',...
            'String', dotList1,...
            'Position', [50 50 100 40],...
            'Callback', @firstDot);
        fDottext=uicontrol('Style','text',...
            'Position',[50 100 100 40],...
            'String','Red dot');
        sDot = uicontrol('Style', 'popup',...
            'String', dotList2,...
            'Position', [150 50 100 40],...
            'Callback', @secondDot);
        sDottext=uicontrol('Style','text',...
            'Position',[150 100 100 40],...
            'String','Blue dot');
        tDot = uicontrol('Style', 'popup',...
            'String', dotList3,...
            'Position', [250 50 100 40],...
            'Callback', @thirdDot);
        tDottext=uicontrol('Style','text',...
            'Position',[250 100 100 40],...
            'String','Green dot');
        runSim2 = uicontrol('Position',[350 50 200 40],'String','Done making figures',...
            'Callback',@makeFig);
        
        uiwait(uiFig4);
        
        if CSD.firstDot==0
            colorDot1=zeros(size(wellOccupPlot{1,1}));
        else
            dot=CSD.firstDot;
            dot1Max=max(max(wellOccupPlot{1,dot}));
            dot1Min=min(min(wellOccupPlot{1,dot}));
            colorDot1=(wellOccupPlot{1,dot}-dot1Min)/(dot1Max-dot1Min);
        end
        if CSD.secondDot==0
            colorDot2=zeros(size(wellOccupPlot{1,1}));
        else
            dot=CSD.secondDot;
            dot1Max=max(max(wellOccupPlot{1,dot}));
            dot1Min=min(min(wellOccupPlot{1,dot}));
            colorDot2=(wellOccupPlot{1,dot}-dot1Min)/(dot1Max-dot1Min);
        end
        if CSD.thirdDot==0
            colorDot3=zeros(size(wellOccupPlot{1,1}));
        else
            dot=CSD.thirdDot;
            dot1Max=max(max(wellOccupPlot{1,dot}));
            dot1Min=min(min(wellOccupPlot{1,dot}));
            colorDot3=(wellOccupPlot{1,dot}-dot1Min)/(dot1Max-dot1Min);
        end
        
        %     dot1=input('Which is the first interesting dot?');
        %     dot2=input('Which is the second interesting dot?');
        %     dot1Max=max(max(wellOccupPlot{1,dot1}));
%         dot2Max=max(max(wellOccupPlot{1,dot2}));
        
        %     dot1Min=min(min(wellOccupPlot{1,dot1}));
%         dot2Min=min(min(wellOccupPlot{1,dot2}));
        
        figure(500); clf; hold on;
        %     colorDot1=(wellOccupPlot{1,dot1}-dot1Min)/(dot1Max-dot1Min);
%         colorDot2=(wellOccupPlot{1,dot2}-dot2Min)/(dot2Max-dot2Min);
        pretendQPC(:,:,1)=colorDot1;
        pretendQPC(:,:,2)=colorDot3;
        pretendQPC(:,:,3)=colorDot2;
        image(colVals,rowVals,pretendQPC);
        ylim([min(rowVals)-CSD.voltStep/2, max(rowVals)+CSD.voltStep/2]);
        xlim([min(colVals)-CSD.voltStep/2, max(colVals)+CSD.voltStep/2]);
        ylabel(['Gate ' CSD.firstGate.name ' Voltage (V)'])
        xlabel(['Gate ' CSD.secondGate.name ' Voltage (V)'])
        set(gca,'Ydir','normal')
        set(gca,'Xdir','normal')
    end
end
%     tempField=getfield(gates,gateNames{j});
%     
%     [xs, ys]=plotForm(tempField.rects);
%     sizex=size(xs);
%     for i=1:sizex(2)
%         fill(xs(:,i),ys(:,i),1)
%     end


    if 0
        
%This stuff is now GUI
%     display('Click first gate to sweep.')
%     [dPoly1, polyn1]=polyClickerDotMap( xpsfine, ypsfine, xminfine, yminfine, polysfine );
%     
%     v1min=input('Minimum voltage on this gate?');
%     v1max=input('Maximum voltage on this gate?');
%     
%     display('Click second gate to sweep.')
%     [dPoly2, polyn2]=polyClickerDotMap( xpsfine, ypsfine, xminfine, yminfine, polysfine );
%     
%     v2min=input('Minimum voltage on this gate?');
%     v2max=input('Maximum voltage on this gate?');
%     vStep=input('Gate voltage step size?');
    
%This stuff is unnecessary due to gates storing this data already!
%     [dvPlotfine1, dvCompfine1, dxmin1, dymin1]=voltMapper(dPoly1, xpsfine,ypsfine);
%     vFineG1=vCompGPU( vXmin, vXmax, vYmin, vYmax, vGridx,vGridy, z0, dvCompfine1 );
%     v1BaseVal=polysfine{polyn1,2};
%     
%     [dvPlotfine2, dvCompfine2, dxmin2, dymin2]=voltMapper(dPoly2, xpsfine,ypsfine);
%     vFineG2=vCompGPU( vXmin, vXmax, vYmin, vYmax, vGridx,vGridy, z0, dvCompfine2 );
%     v2BaseVal=polysfine{polyn2,2};
%     
%     polysWoSweptGates=polysfine;
%     if polyn1>polyn2
%         polysWoSweptGates(polyn1,:)=[];
%         polysWoSweptGates(polyn2,:)=[];
%     elseif polyn1<polyn2
%         polysWoSweptGates(polyn2,:)=[];
%         polysWoSweptGates(polyn1,:)=[];
%     end
%     
%     [plotfineWoSG, dvCompfineWoSG, dxminWoSG, dyminWoSG]=voltMapper(polysWoSweptGates, xpsfine,ypsfine);
%     vFineWoSG=vCompGPU( vXmin, vXmax, vYmin, vYmax, vGridx,vGridy, z0, dvCompfineWoSG );
%     
%     vSelectArea=(v1BaseVal+(v1min+v1max)/2)*vFineG1+(v2BaseVal+(v2min+v2max)/2)*vFineG2+vFineWoSG;
    
    
%This stuff is replaced    
%     display('Please click on the bottom left and upper right corner of the area of interest.')
%     figure(12)
%     h=pcolor(vSelectArea);
%     set(h,'EdgeColor','none');
%     [x, y]=ginput(2);
%     x=round(x);
%     y=round(y);
%     xreal=x*vGridx+xminfine;
%     yreal=y*vGridy+yminfine;
%     vPsiComp=vSelectArea(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1),x(2)]):max([x(1),x(2)]));
%     wellNumber=input('Number of potential wells?');
%     figure(4)
%     h=pcolor(vPsiComp);
%     set(h, 'EdgeColor', 'none')
%     [wellXN, wellYN]=ginput(wellNumber);
%     wellX=vGridx*wellXN*10^-6;
%     wellY=vGridy*wellYN*10^-6;
    
    [ chargeMap,rowVals,colVals ]=dotChargeMap( v1min, v1max, v2min, v2max, vStep, vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y,v1BaseVal,v2BaseVal);
    [ wellOccupPlot ] = plottableChargeMap(chargeMap );
    dot1=input('Which is the first interesting dot?');
    dot2=input('Which is the second interesting dot?');
    pretendQPC=.3*wellOccupPlot{1,dot1}+.5*wellOccupPlot{1,dot2};
    
    figure(500)
    h=surf(colVals,rowVals,pretendQPC);
    set(h,'EdgeColor','none');
    xlabel(['Gate ' num2str(polyn1) ' Voltage (V)'])
    ylabel(['Gate ' num2str(polyn2) ' Voltage (V)'])
    title('Quantum Dot Occupation')
    end
end


