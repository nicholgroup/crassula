function [ derivMat ] = d2dx2( d, r, c )
%UNTITLED Summary of this function goes here

mainDiagVec=(-2/(d)^2)*ones(c,1);
offDiagVec=(1/(d)^2)*ones(c-1,1);
diagMat=diag(mainDiagVec)+diag(offDiagVec,1)+diag(offDiagVec,-1);
derivMat=zeros(r*c);
for j=1:r
    derivMat((j-1)*c+1:j*c,(j-1)*c+1:j*c)=diagMat;
end
end

