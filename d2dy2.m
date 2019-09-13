function [ derivMat ] = d2dy2( d, r, c  )
%UNTITLED2 Summary of this function goes here

mainDiagVec=(-2/(d)^2)*ones(c*r,1);
offDiagVec=(1/(d)^2)*ones(c*(r-1),1);
derivMat=diag(mainDiagVec)+diag(offDiagVec,c)+diag(offDiagVec,-c);

end

