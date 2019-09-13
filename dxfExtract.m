function [gates] = dxfExtract(files, compParams,physParams)%filename , xps, yps, gates)
%[gates, vPlot, vComp, xmin, ymin, polys] 
%Takes a DXF file and converts it into a form which is usable for computing
%the potential.  This is done in three parts.

gates=struct;

for i=1:size(files.gateFiles,2)
    %Uses f_LectDxf to extract the contents of the dxf folder.  Got this off
    %the internet.  Did not write it myself.
    
    dxfout=f_LectDxf(files.gateFiles{i});
        
    %Generates polygons from the dxf files output.
    %polys is a cell which contains the polygons in DXF in a more convenient
    %form.
    [gateNames, polystemp]=polyGenV(dxfout);
    
    %Generates the potential map at the surface from the polygons.
    %vPlot is for plotting in pcolor or surf.  vComp is for the actual computations.
    %xmin and ymin give the coordinates of the bottom left corner of the
    %voltage map which is necessary for knowing how to offset different DXF
    %files relative to each other.
    [gates, xmintemp, ymintemp]=rectCreator(gates, polystemp, gateNames, compParams.rectGrid(i),physParams.z0s(i));
    
end
end

