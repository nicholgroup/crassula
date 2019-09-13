function [ saveFileName ] = saveGates( gates, compParams )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
uiFig=figure(1001); clf

    function savefilename(source,callbackdata)
%         a = get(source,'string');
        saveFileName=[source.String, '.mat'];
        save(saveFileName,'gates','compParams')
        uiresume(gcbf)
        close(uiFig)
    end

    function saver(x,y)
        uiresume(gcbf)
        figure(1001);clf
        uicontrol('Style','edit',...
            'Position',[300 100 200 40],...
            'String','yourFileNameHere',...
            'Callback',@savefilename);
        uicontrol('Style','text',...
            'Position',[100 90 200 40],...
            'String','Savefile name?  Do not add .mat');
        uiwait(gcf);
    end
    function notsaver(x,y)
        saveFileName='youDidntSaveYouDummy.mat';
        uiresume(gcbf)
        close(uiFig)
    end

figure(1001)
set(1001,'pos',[300 100 600 200])
g = uicontrol('Position',[100 100 200 40],'String','Save (Recommended)',...
    'Callback',@saver);
h = uicontrol('Position',[300 100 200 40],'String','Do not save',...
    'Callback',@notsaver);
uiwait(gcf); 



end

