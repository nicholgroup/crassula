function [ dv ] = finiteRecVFromRect( x,y,z,L,B,R,T)
%UNTITLED36 Summary of this function goes here
%   Detailed explanation goes here
x1=x-L;
x2=R-x;
y1=y-B;
y2=T-y;
dv=g(x1,y1,z)+g(x1,y2,z)+g(x2,y1,z)+g(x2,y2,z);

end

