function [ xs, ys ] = plotForm( vComp )
%Converts the computation rectangles into a form that can be plotted.
vcsize=size(vComp);
xs=zeros(4,vcsize(2));
ys=zeros(4,vcsize(2));
for i=1:vcsize(2);
    xs(1,i)=vComp(1,i);
    xs(2,i)=vComp(3,i);
    xs(3,i)=vComp(3,i);
    xs(4,i)=vComp(1,i);
    ys(1,i)=vComp(2,i);
    ys(2,i)=vComp(2,i);
    ys(3,i)=vComp(4,i);
    ys(4,i)=vComp(4,i);
end

end

