function [ Vden ] = vConvDen( Vv )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[r,c]=size(Vv);
vVec=zeros(1,r*c);
for j=1:r
    for k=1:c
    vVec((j-1)*c+k)=Vv(j,k);
    end
end
Vden=diag(vVec);
end

