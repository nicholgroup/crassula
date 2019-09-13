function [ voltAtJ ] = Vhvoltage(j,d,x,y,distmin,epsilon)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
jx=x(j);
jy=y(j);
relx=x-jx;
relx(j)=distmin;
rely=y-jy;
rely(j)=distmin;
voltAtJ=sum(d./(4*pi*epsilon*(relx.^2+rely.^2).^.5));
end

