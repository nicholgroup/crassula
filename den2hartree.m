function [ Vh ] = den2hartree( d,x,y,distmin,epsilon )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
npts=length(d);
Vhvec=zeros(npts,1);
for j=1:npts
    Vhvec(j)=Vhvoltage(j,d,x,y,distmin,epsilon);
end
Vh=diag(Vhvec);
end

