function [ V ] = vFromRect( x,y,z,vComp)
%assumes a unit voltage.  Multiplication happens outside.  Only need to
%calculate this geometric factor once this way!
V=0;
vs=size(vComp);
for k=1:vs(2)
    V=V+finiteRecVFromRect(x,y,z,vComp(1,k),vComp(2,k),vComp(3,k),vComp(4,k));
end
end

