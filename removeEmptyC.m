function [ new ] = removeEmptyC( vComp )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
new=vComp;
old=new;
oldsize=size(old);
counter=0;

for j=1:oldsize(2)-1
    if (old(1,j)==0) && (old(2,j)==0) && (old(3,j)==0) && (old(4,j)==0) && (old(5,j)==0)
        new=horzcat(new(:,1:j-counter-1),new(:,j+1-counter:end));
        counter=counter+1;
    end
end

if (old(1,end)==0) && (old(2,end)==0) && (old(3,end)==0) && (old(4,end)==0) && (old(5,end)==0)
    new=new(:,1:end-1);
end


end

