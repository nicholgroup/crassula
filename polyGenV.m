function [ gateNames, polys ] = polyGenV(dxfOut)
%Takes the output of the dxf converter and generates polygons which are
%easy to work with.  polys is a cell.  Each row is a separate polygon.  the
%first column is a list of the corners of the polygon.  The second is the
%name of the layer.  The layer name should be the desired voltage which is
%a string, not a number.

dxfsize=size(dxfOut);
counter=1;%which polygon it is working on

%Creates the polygon cell 
polys={[dxfOut{1,1}(1,1),dxfOut{1,1}(1,2)]};
polys{1,2}=dxfOut{1,1}(1,3);
gateNames{1}=dxfOut{1,2};


for j=2:dxfsize(1);
    %Add this point to the current polygon
    if dxfOut{j,1}(1,1)==dxfOut{j-1,1}(1,4) && dxfOut{j,1}(1,2)==dxfOut{j-1,1}(1,5);
        polys{counter,1}=vertcat(polys{counter,1},[dxfOut{j,1}(1,1),dxfOut{j,1}(1,2)]);%add x and y value of the point
    
    %Start a new polygon
    else
        counter=counter+1;
        polys{counter,1}=[dxfOut{j,1}(1,1),dxfOut{j,1}(1,2)];%Add x and y value
        polys{counter,2}=dxfOut{j,1}(1,3);
        gateNames{counter}=dxfOut{j,2};%Store the layer name, a string of the voltage value.
    end
end
end

