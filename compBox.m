function [ xmin, xmax, ymin, ymax] = compBox( filename)
%Generates a the computation grid from a dxf file.  2004 version of dxf works well.
%Use only lines.  Make sure the polygons are closed.  Save the charge as
%the layer name.  Note that this is very similar in form to dxf2voltage.m
%which is probably better commmented.

%Uses f_LectDxf to extract the contents of the dxf folder.  Got this off
%the internet.  Did not write it myself.
dxfout=f_LectDxf(filename);

%Generates polygons from the dxf files output.
[~, polys]=polyGenV(dxfout);

polysize=size(polys);

xminvec=zeros(1,polysize(1));
yminvec=zeros(1,polysize(1));
xmaxvec=zeros(1,polysize(1));
ymaxvec=zeros(1,polysize(1));

for m=1:polysize(1);
    xminvec(m)=min(polys{m,1}(:,1));
    yminvec(m)=min(polys{m,1}(:,2));
    xmaxvec(m)=max(polys{m,1}(:,1));
    ymaxvec(m)=max(polys{m,1}(:,2));
end

xmin=min(xminvec);
ymin=min(yminvec);
xmax=max(xmaxvec);
ymax=max(ymaxvec);
end

