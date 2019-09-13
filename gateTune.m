function [ gates, continueTuning] = gateTune( gates,compParams,opts )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% % Add a text uicontrol to label the slider.

continueTuning=1;%need to add button to break the loop later

gateNames=sort(fieldnames(gates));

    function masterFun(source,gate2set)
        
        %JMN
        %a = get(source,'string');
        %v=str2double(a);
        
        v = get(source,'Value');

        
        %    vSet=setfield(vSet,gate2set,v);
        tempField=getfield(gates,gate2set);
        tempField.setVoltage=v;
        gates=setfield(gates,gate2set,tempField);
    end

    function doneTuning(x,y)
        continueTuning=0;
        uiresume(gcbf)
    end

%vSet=struct;
uiFunctions=struct;

for j=1:size(gateNames,1)
    tempField=getfield(gates,gateNames{j});
    %vSet=setfield(vSet,gateNames{j},getfield(tempField,'setVoltage'));
    f=@(source,callbackdata) masterFun(source,gateNames{j});
    uiFunctions=setfield(uiFunctions,gateNames{j},f);
end


figure(1000); clf
set(1000,'pos',[300 100 550 25*(1+size(gateNames,1))]);
h = uicontrol('Position',[300 20 200 40],'String','Replot with new voltages',...
              'Callback','uiresume(gcbf)');
g = uicontrol('Position',[300 100 200 40],'String','Done tuning',...
              'Callback',@doneTuning);

for j=1:size(gateNames,1)
    k=size(gateNames,1)+1-j;
    tempField=getfield(gates,gateNames{k});
    uicontrol('Style','slider',...
        'Min',-1,'Max',1,'Value',tempField.setVoltage,...
        'Position',[150 25*j-10 120 20],...
        'String',num2str(tempField.setVoltage),...
        'Callback',getfield(uiFunctions,gateNames{k}));
    uicontrol('Style','text',...
        'Position',[0 25*j-10 120 20],...
        'String',[gateNames{k},'     ',num2str(tempField.setVoltage)]);
end

% %original JMN
% for j=1:size(gateNames,1)
%     k=size(gateNames,1)+1-j;
%     tempField=getfield(gates,gateNames{k});
%     uicontrol('Style','edit',...
%         'Position',[150 25*j-10 120 20],...
%         'String',num2str(tempField.setVoltage),...
%         'Callback',getfield(uiFunctions,gateNames{k}));
%     uicontrol('Style','text',...
%         'Position',[0 25*j-10 120 20],...
%         'String',gateNames{k});
% end

uiwait(gcf); 

gateVPlotter( gates, opts )
voltPlot2DEG( gates, compParams, opts );

end

