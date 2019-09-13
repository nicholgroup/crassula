function [ ] = gateVPlotter( gates,opts )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

gateNames=sort(fieldnames(gates));

%Find the max and min voltage applied to a gate to give a color scale for
%plotting
tempField=getfield(gates,gateNames{1});
minGateV=tempField.setVoltage;
maxGateV=tempField.setVoltage;
for j=1:size(gateNames,1)
    tempField=getfield(gates,gateNames{j});
    if tempField.setVoltage<minGateV
        minGateV=tempField.setVoltage;
    end
    if tempField.setVoltage>maxGateV
        maxGateV=tempField.setVoltage;
    end
end

%Plot the voltages on the gates.  Red negative and blue positive
figure(1); clf; hold on
for j=1:size(gateNames,1)
    tempField=getfield(gates,gateNames{j});
    if tempField.setVoltage<0
        color=[1 1-(tempField.setVoltage/minGateV) 1-(tempField.setVoltage/minGateV)];
    elseif tempField.setVoltage==0
        color=[1,1,1];
    else
        color=[1-(tempField.setVoltage/maxGateV) 1-(tempField.setVoltage/maxGateV) 1];
    end
    
    for i=1:size(tempField.polysX,2)
        fill(tempField.polysX{i},tempField.polysY{i},color)
    end
end

end

