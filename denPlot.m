function [ dPlot ] = denPlot( d,r,c )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
dPlot=zeros(r,c);
counter=1;
for j=1:r
    for k=1:c
        dPlot(j,k)=d(counter);
        counter=counter+1;
    end
end

end

