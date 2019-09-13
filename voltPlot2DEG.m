function [ voltageMap ] = voltPlot2DEG( gates, compParams, opts )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%Plots the voltage at the 2DEG

gateNames=sort(fieldnames(gates));

tempField=getfield(gates,gateNames{1});
min2DEGV=min(min(tempField.unitVoltageMap*tempField.setVoltage));
max2DEGV=max(max(tempField.unitVoltageMap*tempField.setVoltage));
voltageMap=zeros(size(tempField.unitVoltageMap,1),size(tempField.unitVoltageMap,2));

for j=1:size(gateNames,1)
    tempField=getfield(gates,gateNames{j});
    gateVoltageMap=tempField.unitVoltageMap*tempField.setVoltage;
    voltageMap=voltageMap+gateVoltageMap;
    
    if min(min(tempField.unitVoltageMap*tempField.setVoltage))<min2DEGV
        min2DEGV=min(min(tempField.unitVoltageMap*tempField.setVoltage));
    elseif max(max(tempField.unitVoltageMap*tempField.setVoltage))>max2DEGV
        max2DEGV=max(max(tempField.unitVoltageMap*tempField.setVoltage));
    end
    
end
figure(2)
h = pcolor(compParams.vXs,compParams.vYs,voltageMap);
set(h, 'EdgeColor', 'none')
colorbar;

%Plot the voltage profile from every gate independently
if exist('opts','var')
    if opts.indGatePlot
        figure(200); clf
        subPlotNumRow=ceil(sqrt(size(gateNames,1)));
        subPlotNumCol=subPlotNumRow;
        while subPlotNumCol*subPlotNumRow>size(gateNames,1)
            subPlotNumRow=subPlotNumRow-1;
        end
        subPlotNumRow=subPlotNumRow+1;
        for j=1:size(gateNames,1)
            tempField=getfield(gates,gateNames{j});
            figure(200); subplot(subPlotNumRow,subPlotNumCol,j)
            gateVoltageMap=tempField.unitVoltageMap*tempField.setVoltage;
            h = pcolor(gateVoltageMap);
            set(h, 'EdgeColor', 'none')
            title(gateNames{j})
            caxis([min2DEGV max2DEGV])
        end
    end
end
figure(2)
end

