function [ gates, compParams ] = voltageComp(gates,files,compParams)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

vGrid=compParams.vGrid;

gateNames=fieldnames(gates);


%Opens the filenamecomp to find the area where the voltage in the 2DEG
%should be computed.
[vXmin, vXmax, vYmin, vYmax]=compBox(files.compBox);

for i=1:size(gateNames,1)
    fieldTemp=getfield(gates,gateNames{i});
    z0=fieldTemp.z0;
    vComp=fieldTemp.rects;
    Vset=fieldTemp.setVoltage;
    Vout=zeros(1+round((vYmax-vYmin)/vGrid),1+round((vXmax-vXmin)/vGrid));
    Vsize=size(Vout);
%     Vout=gpuArray(Vout);
    for j=1:Vsize(2)
        parfor k=1:Vsize(1)
            Vout(k,j)=vFromRect(vXmin+(j-1)*vGrid,vYmin+(k-1)*vGrid,z0,vComp);
        end
    end
%     Vout=gather(Vout);
    fieldTemp.unitVoltageMap=Vout;
    gates=setfield(gates,gateNames{i},fieldTemp);
end

compParams.vXs=vXmin+vGrid.*[0:size(Vout,2)-1];
compParams.vYs=vYmin+vGrid.*[0:size(Vout,1)-1];
end

