function [ gates, compParams, V ] = chargeGroundStateFinder( gates, compParams, physParams, opts, V)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% computeD=input('Compute the electron density?');
%Get the names of all the gates

    function strtGSF(~,~)
        computeD=1;
        uiresume(gcbf)
        close(uiFig)
    end
    function nope(~,~)
        computeD=0;
        uiresume(gcbf)
        close(uiFig)
    end

    function posClicker(~,~)
        figure(2)
        [xReal, yReal]=ginput(2);
        [~,x]=min([abs(compParams.vXs-xReal(1)); abs(compParams.vXs-xReal(2))] ,[],2);
        [~,y]=min([abs(compParams.vYs-yReal(1)); abs(compParams.vYs-yReal(2))] ,[],2);
        
        %JMN 2017/11/20
        %[~,y]=min(abs(compParams.vYs-yReal),[],2);
        %[~,x]=min(abs(compParams.vXs-xReal),[],2);
        vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        compParams.vXsmall=compParams.vXs(min(x):max(x));
        compParams.vYsmall=compParams.vYs(min(y):max(y));
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

    function LEfun(source,~)
        a = get(source,'string');
        vX=str2double(a);
        [~,vXgridNumNew]=min(abs(compParams.vXs-vX),[],2);
        [~,vXgridNumOld]=min(abs(compParams.vXs-compParams.vXsmall(end)),[],2);
        x=[vXgridNumOld,vXgridNumNew];
        [~,y]=min(abs(compParams.vYs-[compParams.vYsmall(1);compParams.vYsmall(end)]),[],2);
        compParams.vXsmall=compParams.vXs(min(x):max(x));
        vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
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
        vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
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
        vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
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
        vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
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
        set(h, 'EdgeColor', 'none')
        hold on;
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
%         plot(wellX,wellY,'k+','MarkerSize',20,'LineWidth',5)
        uiresume(uiFig2)
    end
uiFig=figure(1001);
set(1001,'pos',[300 100 600 200])
g = uicontrol('Position',[100 100 200 40],'String','Compute electrons ground state?',...
    'Callback',@strtGSF);
h = uicontrol('Position',[300 100 200 40],'String','Nope',...
    'Callback',@nope);
uiwait(gcf);

if ~isfield(compParams,'vXsmall')
    compParams.vXsmall=compParams.vXs;
end
if ~isfield(compParams,'vYsmall')
    compParams.vYsmall=compParams.vYs;
end
if ~isfield(compParams,'wellNumber')
    compParams.wellNumber=1;
end
if isfield(compParams,'wellX')
    autoWellPos=0;
    if isfield(compParams,'wellX')
        figure(4); hold on;
        plot(compParams.wellX,compParams.wellY,'k+','MarkerSize',20,'LineWidth',5)
        for fontCount=1:length(compParams.wellX)
            text(compParams.wellX(fontCount),compParams.wellY(fontCount),['    ' num2str(fontCount)],'Color','k', 'FontSize',12)
        end
    end
else
    autoWellPos=1;
end

vPsiComp=V;


while computeD
    waitToSim=1;
    while waitToSim
        uiFig2=figure(1002); clf;
        set(1002,'pos',[300 100 800 200])
        
        LEtext=uicontrol('Style','text',...
            'Position',[50 75 50 40],...
            'String','Lower x coord');
        uicontrol('Style','edit',...
            'Position',[100 75 75 40],...
            'String',num2str(compParams.vXsmall(1)),...
            'Callback',@LEfun);
        
        REtext=uicontrol('Style','text',...
            'Position',[50 25 50 40],...
            'String','Upper x coord');
        uicontrol('Style','edit',...
            'Position',[100 25 75 40],...
            'String',num2str(compParams.vXsmall(end)),...
            'Callback',@REfun);
        
        BEtext=uicontrol('Style','text',...
            'Position',[200 75 50 40],...
            'String','Lower y coord');
        uicontrol('Style','edit',...
            'Position',[250 75 75 40],...
            'String',num2str(compParams.vYsmall(1)),...
            'Callback',@BEfun);
        
        TEtext=uicontrol('Style','text',...
            'Position',[200 25 50 40],...
            'String','Upper y coord');
        uicontrol('Style','edit',...
            'Position',[250 25 75 40],...
            'String',num2str(compParams.vYsmall(end)),...
            'Callback',@TEfun);
        
        clickPos = uicontrol('Position',[50 125 200 40],'String','Click to get position',...
            'Callback',@posClicker);
        runSim = uicontrol('Position',[600 125 200 40],'String','Run simulation',...
            'Callback',@simRun);
       
        Welltext=uicontrol('Style','text',...
            'Position',[350 125 50 40],...
            'String','Number of dots');
        uicontrol('Style','edit',...
            'Position',[400 125 75 40],...
            'String',num2str(compParams.wellNumber),...
            'Callback',@Wellfun);
        runSim = uicontrol('Position',[350 75 200 40],'String','Select well locations',...
            'Callback',@wellPosFun);
        
        %JMN 2017/11/20
%         [~,y]=min(abs(compParams.vYs-[compParams.vYsmall(1);compParams.vYsmall(end)]),[],2);
%         [~,x]=min(abs(compParams.vXs-[compParams.vXsmall(1);compParams.vXsmall(end)]),[],2);

        [~,y]=min([abs(compParams.vYs-compParams.vYsmall(1)); abs(compParams.vYs-compParams.vYsmall(end))],[],2);
        [~,x]=min([abs(compParams.vXs-compParams.vXsmall(1)); abs(compParams.vXs-compParams.vXsmall(end))],[],2);

        vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
        
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
        uiwait(uiFig2);
        
    end
%     
%     compParams.wellX=compParams.wellX-compParams.vXsmall(1);
%     compParams.wellY=compParams.wellY-compParams.vYsmall(1);
    
    [evalFinal, densityFinal, psiFinal, occupFinal] = densitySolver(vPsiComp,compParams,physParams);
    %     computeD=input('Tune the gates and recompute the electron density?');
    
%     compParams.wellX=compParams.wellX+compParams.vXsmall(1);
%     compParams.wellY=compParams.wellY+compParams.vYsmall(1);
    
    uiFig=figure(1001);
    set(1001,'pos',[300 100 600 200])
    g = uicontrol('Position',[100 100 200 40],'String','Tune gates and recompute electrons ground state?',...
        'Callback',@strtGSF);
    h = uicontrol('Position',[300 100 200 40],'String','Nope',...
        'Callback',@nope);
    uiwait(gcf);
    
    if computeD
        continueTuning=1;
        while continueTuning
            [gates, continueTuning]=gateTune(gates, compParams, opts);
        end
        
        newSaveFile=saveGates(gates, compParams);
        
        V=voltPlot2DEG( gates, compParams, opts );
        densityPlot2DEG( V, compParams,physParams );
    end
end

end

