function [ dg ] = g( u,v,z )
%UNTITLED39 Summary of this function goes here
%   Detailed explanation goes here
dg=atan2(u*v,z*(u^2+v^2+z^2)^.5)/(2*pi);
end

