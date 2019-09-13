function [ occup ] = whichWell( psi, x, y, wellX, wellY )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
wellNumber=length(wellX);
distances=zeros(1,wellNumber);
xExp=psi'*diag(x)*psi;
yExp=psi'*diag(y)*psi;
for j=1:wellNumber
    distances(1,j)=distance(xExp, yExp, wellX(j,1), wellY(j,1));
end
[distances, order]=sort(distances);

occup=zeros(1,wellNumber);
occup(order(1))=1;
end

