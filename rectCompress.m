function [ new ] = rectCompress( vComp,xps,yps )
%Compresses a bunch of adjacent rectangles into one big rectangle.

%somtimes vComp rows that are just all zeros.  This gets rid of
%them as they are a bug.
new=removeEmptyC(vComp);

old=new;
oldsize=size(old);
for j=1:oldsize(2)-1%For all the rectangles
    if (round(new(2,j)/xps)==round(new(2,j+1)/xps)) && (round(new(4,j)/xps)==round(new(4,j+1)/xps)) && (round(new(5,j)/yps)==round(new(3,j+1)/yps))
    %Is rect j right above to rect j+1?
        new(5,j)=new(5,j+1);%make rect j include rect j+1 and make rect j+1 empty
        new(:,j+1)=[0;0;0;0;0];
    %Is rect j right next to rect j+1?
    elseif (round(new(3,j)/yps)==round(new(3,j+1)/yps)) && (round(new(5,j)/yps)==round(new(5,j+1)/xps)) && (round(new(4,j)/xps)==round(new(2,j+1)/xps))
        new(4,j)=new(4,j+1);%make rect j include rect j+1 and make rect j+1 empty
        new(:,j+1)=[0;0;0;0;0];
    end
end

new=removeEmptyC(new);%delete the empty rectangles that came from condensing
so=size(old);
sn=size(new);

while so(2)~=sn(2)%Did the last iteration make a change to the number of rectangles?  If so, run it again to make sure its really compressed all the way.
    old=new;
    oldsize=size(old);
    %See comments above.
    for j=1:oldsize(2)-1
        if (round(new(2,j)/xps)==round(new(2,j+1)/xps)) && (round(new(4,j)/xps)==round(new(4,j+1)/xps)) && (round(new(5,j)/yps)==round(new(3,j+1)/yps))
            new(5,j)=new(5,j+1);
            new(:,j+1)=[0;0;0;0;0];
        elseif (round(new(3,j)/yps)==round(new(3,j+1)/yps)) && (round(new(5,j)/yps)==round(new(5,j+1)/xps)) && (round(new(4,j)/xps)==round(new(2,j+1)/xps))
            new(4,j)=new(4,j+1);
            new(:,j+1)=[0;0;0;0;0];
        end
    end
    new=removeEmptyC(new);
    so=size(old);
    sn=size(new);
end


% Reshuffle so its sorted by x values.  This and the next step make sure
% that it is maximally compresssed.

[~, order] = sort(new(2,:));
new = new(:,order);

old=new;
oldsize=size(old);
for j=1:oldsize(2)-1
    if (round(new(2,j)/xps)==round(new(2,j+1)/xps)) && (round(new(4,j)/xps)==round(new(4,j+1)/xps)) && (round(new(5,j)/yps)==round(new(3,j+1)/yps))
        new(5,j)=new(5,j+1);
        new(:,j+1)=[0;0;0;0;0];
    elseif (round(new(3,j)/yps)==round(new(3,j+1)/yps)) && (round(new(5,j)/yps)==round(new(5,j+1)/xps)) && (round(new(4,j)/xps)==round(new(2,j+1)/xps))
        new(4,j)=new(4,j+1);
        new(:,j+1)=[0;0;0;0;0];
    end
end

new=removeEmptyC(new);
so=size(old);
sn=size(new);

while so(2)~=sn(2)
    old=new;
    oldsize=size(old);
    for j=1:oldsize(2)-1
        if (round(new(2,j)/xps)==round(new(2,j+1)/xps)) && (round(new(4,j)/xps)==round(new(4,j+1)/xps)) && (round(new(5,j)/yps)==round(new(3,j+1)/yps))
            new(5,j)=new(5,j+1);
            new(:,j+1)=[0;0;0;0;0];
        elseif (round(new(3,j)/yps)==round(new(3,j+1)/yps)) && (round(new(5,j)/yps)==round(new(5,j+1)/xps)) && (round(new(4,j)/xps)==round(new(2,j+1)/xps))
            new(4,j)=new(4,j+1);
            new(:,j+1)=[0;0;0;0;0];
        end
    end
    new=removeEmptyC(new);
    so=size(old);
    sn=size(new);
end


% Reshuffle so its sorted by y values.  This and the previous step make sure
% that it is maximally compresssed.
[~, order] = sort(new(3,:));
new = new(:,order);

old=new;
oldsize=size(old);
for j=1:oldsize(2)-1
    if (round(new(2,j)/xps)==round(new(2,j+1)/xps)) && (round(new(4,j)/xps)==round(new(4,j+1)/xps)) && (round(new(5,j)/yps)==round(new(3,j+1)/yps))
        new(5,j)=new(5,j+1);
        new(:,j+1)=[0;0;0;0;0];
    elseif (round(new(3,j)/yps)==round(new(3,j+1)/yps)) && (round(new(5,j)/yps)==round(new(5,j+1)/xps)) && (round(new(4,j)/xps)==round(new(2,j+1)/xps))
        new(4,j)=new(4,j+1);
        new(:,j+1)=[0;0;0;0;0];
    end
end

new=removeEmptyC(new);
so=size(old);
sn=size(new);

while so(2)~=sn(2)
    old=new;
    oldsize=size(old);
    for j=1:oldsize(2)-1
        if (round(new(2,j)/xps)==round(new(2,j+1)/xps)) && (round(new(4,j)/xps)==round(new(4,j+1)/xps)) && (round(new(5,j)/yps)==round(new(3,j+1)/yps))
            new(5,j)=new(5,j+1);
            new(:,j+1)=[0;0;0;0;0];
        elseif (round(new(3,j)/yps)==round(new(3,j+1)/yps)) && (round(new(5,j)/yps)==round(new(5,j+1)/xps)) && (round(new(4,j)/xps)==round(new(2,j+1)/xps))
            new(4,j)=new(4,j+1);
            new(:,j+1)=[0;0;0;0;0];
        end
    end
    new=removeEmptyC(new);
    so=size(old);
    sn=size(new);
end

end

