function [ wellOccupPlot ] = plottableChargeMap(chargeMap )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
rows=size(chargeMap,1);
cols=size(chargeMap,2);
wells=size(chargeMap{1,1},2);
wellOccupPlot=cell(1,wells);
for j=1:wells
    tempMat=zeros(rows,cols);
    for k=1:rows
        for l=1:cols
            tempMat(k,l)=chargeMap{k,l}(j);
        end
    end
    wellOccupPlot{1,j}=tempMat;
end
end

