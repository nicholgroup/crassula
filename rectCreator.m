function [gates, xmin, ymin ] = rectCreator( gates, polys, gateNames, rectGrid,z0 )
%Takes the polygons from polyGenV and turns them into a form which can be used for plotting and computation.
%vPlot is for plotting in pcolor or surf.  vComp is for the actual computations.
%xmin and ymin give the coordinates of the bottom left corner of the
%voltage map which is necessary for knowing how to offset different DXF
%files relative to each other.

xps=rectGrid;
yps=rectGrid;
polysize=size(polys);%polysize(1) is the number of polygons
polysR=polys;


%% Round the polygons off so that the corners are on the grid from xps and yps.
for j=1:polysize(1)%for each of the polygons
    polysR{j,1}(:,1)=xps*round(polys{j,1}(:,1)/xps);
    polysR{j,1}(:,2)=yps*round(polys{j,1}(:,2)/yps); 
end

%% Figure out how big vPlot needs to be
xminvec=zeros(1,polysize(1));
yminvec=zeros(1,polysize(1));
xmaxvec=zeros(1,polysize(1));
ymaxvec=zeros(1,polysize(1));

for m=1:polysize(1);
    xminvec(m)=min(polysR{m,1}(:,1));
    yminvec(m)=min(polysR{m,1}(:,2));
    xmaxvec(m)=max(polysR{m,1}(:,1));
    ymaxvec(m)=max(polysR{m,1}(:,2));
end

xmin=min(xminvec);
ymin=min(yminvec);
xmax=max(xmaxvec);
ymax=max(ymaxvec);
% vPlot=zeros(round((ymax-ymin)/yps),round((xmax-xmin)/xps));

%% Shifted Polygons
% Shifts the polygons by .5 xps and .yps.  This is later used to figure out
% which points are inside the polygon.  Each point on the grid is
% associated with the xps by yps square to the upper right of it.  By
% searching through all points on the grid and seeing which are inside the
% shifted polygon and adding their associated squares together, the polygon
% is reproduced.
polyShift=polysR;
for j=1:polysize(1)%for each of the polygons
polyShift{j,1}(:,1)=polyShift{j,1}(:,1)-.5*xps;
polyShift{j,1}(:,2)=polyShift{j,1}(:,2)-.5*yps;
end

%% Generates vComp and vPlot
vComptemp=cell(1,polysize(1));

for n=1:polysize(1);%for each polygon
    %Need to figure out which positions have voltage.  Make a box around the
    %polygon and check which points are in the polygon.  This is used to
    %generate a bunch of rectangles that represent the polygon for
    %computation and a bunch of points for plotting.
    
    %size of polygon
    qsearch=[min(polysR{n,1}(:,1)), max(polysR{n,1}(:,1)), min(polysR{n,1}(:,2)), max(polysR{n,1}(:,2))];
    %Is the polygon longer in the x or y direction?  Make better
    %computation rectangles.
    
    polyXs=polysR{n,1}(:,1);
    polyYs=polysR{n,1}(:,2);
%     polyXs=polys{n,1}(:,1);
%     polyYs=polys{n,1}(:,2);
    nPolyPoints=length(polyXs);
    polyXs=vertcat(polyXs,polyXs(1));
    polyYs=vertcat(polyYs,polyYs(1));

    voltn=polysR{n,2};%voltage of nth polygon
    rectcounter=0;
    
    %ydirection is longer
    if (qsearch(4)-qsearch(3))>(qsearch(2)-qsearch(1))
%         rectcounter=1;
        vComptemp{1,n}=zeros(5,round((qsearch(2)-qsearch(1))/xps)-1);%prepares a matrix in the proper cell spot of vComp.  Matlab is more efficient if the matrix size isnt changed each time
        for k=qsearch(1):xps:qsearch(2)-xps;%all x coords in the box
%         for k=qsearch(1):xps:qsearch(2);%all x coords in the box
            yEdges=[];
            for pointCounter=1:nPolyPoints
                if ((k+xps/2>=polyXs(pointCounter)) && (k+xps/2<=polyXs(pointCounter+1)))||((k+xps/2<=polyXs(pointCounter)) && (k+xps/2>=polyXs(pointCounter+1)))
%                     yvalRaw=polyYs(pointCounter)+(k-polyXs(pointCounter))*(polyYs(pointCounter+1)-polyYs(pointCounter))/(polyXs(pointCounter+1)-polyXs(pointCounter));
                    yvalRaw=polyYs(pointCounter)+(k+xps/2-polyXs(pointCounter))*(polyYs(pointCounter+1)-polyYs(pointCounter))/(polyXs(pointCounter+1)-polyXs(pointCounter));
                    yval=yps*round(yvalRaw/yps);
                    yEdges=vertcat(yEdges,yval);
                end
            end
            yEdges=unique(sort(yEdges));
            if length(yEdges)==2
                vComptempMat=zeros(5,1);
                vComptempMat(1)=voltn;%voltage of rectangle
                vComptempMat(2)=k;%xvalue of bottom left corner
                vComptempMat(3)=yEdges(1);%yvalue of bottom left corner
                vComptempMat(4)=min([k+xps,xmaxvec(n)]);%xvalue of top right corner
                vComptempMat(5)=yEdges(2);%yvalue of tope right corner
                vComptemp{1,n}=horzcat(vComptemp{1,n},vComptempMat);
%                 for l=yEdges(1):yps:yEdges(2)-yps
%                     vPlot(round(1+(l-ymin)/yps),round(1+(k-xmin)/xps))=voltn;
%                 end
            elseif length(yEdges)>2
                yMids=(yEdges(1:end-1)+yEdges(2:end))./2;
                for apple=1:length(yMids)
                    [inpoly, ~]=inpolygon(k+xps/2,yMids(apple),polyXs,polyYs);
%                     [inpoly, ~]=inpolygon(k,yMids(apple),polyXs,polyYs);
%                     [inpoly, ~]=inpolygon(k,yMids(apple),polyShift{n,1}(:,1), polyShift{n,1}(:,2));
                    if inpoly
                        vComptempMat=zeros(5,1);
                        vComptempMat(1)=voltn;%voltage of rectangle
                        vComptempMat(2)=k;%xvalue of bottom left corner
                        vComptempMat(3)=yEdges(apple);%yvalue of bottom left corner
                        vComptempMat(4)=min([k+xps,xmaxvec(n)]);%xvalue of top right corner
                        vComptempMat(5)=yEdges(apple+1);%yvalue of tope right corner
                        vComptemp{1,n}=horzcat(vComptemp{1,n},vComptempMat);
%                         for l=yEdges(apple):yps:yEdges(apple+1)-yps
%                             vPlot(round(1+(l-ymin)/yps),round(1+(k-xmin)/xps))=voltn;
%                         end
                    end
                end
                
            end
        end
            
    %xdriection is longer
    else
        vComptemp{1,n}=zeros(5,round((qsearch(4)-qsearch(3))/yps)-1);%prepares a matrix in the proper cell spot of vComp.  Matlab is more efficient if the matrix size isnt changed each time
        for l=qsearch(3):yps:qsearch(4)-yps;%all y coords in teh box
%         for l=qsearch(3):yps:qsearch(4);%all y coords in teh box
            xEdges=[];
            for pointCounter=1:nPolyPoints
                if ((l+yps/2>=polyYs(pointCounter)) && (l+yps/2<=polyYs(pointCounter+1)))||((l+yps/2<=polyYs(pointCounter)) && (l+yps/2>=polyYs(pointCounter+1)))
%                     xvalRaw=polyXs(pointCounter)+(l-polyYs(pointCounter))*(polyXs(pointCounter+1)-polyXs(pointCounter))/(polyYs(pointCounter+1)-polyYs(pointCounter));
                    xvalRaw=polyXs(pointCounter)+(l+yps/2-polyYs(pointCounter))*(polyXs(pointCounter+1)-polyXs(pointCounter))/(polyYs(pointCounter+1)-polyYs(pointCounter));
                    xval=xps*round(xvalRaw/xps);
                    xEdges=vertcat(xEdges,xval);
                end
            end
            xEdges=unique(sort(xEdges));
            if length(xEdges)==2
                vComptempMat=zeros(5,1);
                vComptempMat(1)=voltn;%voltage of rectangle
                vComptempMat(2)=xEdges(1);%xvalue of bottom left corner
                vComptempMat(3)=l;%yvalue of bottom left corner
                vComptempMat(4)=xEdges(2);%xvalue of top right corner
                vComptempMat(5)=min([l+yps,ymaxvec(n)]);%yvalue of tope right corner
                vComptemp{1,n}=horzcat(vComptemp{1,n},vComptempMat);
%                 for k=xEdges(1):xps:xEdges(2)-xps
%                     vPlot(round(1+(l-ymin)/yps),round(1+(k-xmin)/xps))=voltn;
%                 end
            elseif length(xEdges)>2
                xMids=(xEdges(1:end-1)+xEdges(2:end))./2;
                for apple=1:length(xMids)
                    [inpoly, ~]=inpolygon(xMids(apple),l+yps/2,polyXs,polyYs);
%                     [inpoly, ~]=inpolygon(xMids(apple),l,polyXs,polyYs);
%                     [inpoly, ~]=inpolygon(xMids(apple),l,polyShift{n,1}(:,1), polyShift{n,1}(:,2));
                    if inpoly
                        vComptempMat=zeros(5,1);
                        vComptempMat(1)=voltn;%voltage of rectangle
                        vComptempMat(2)=xEdges(apple);%xvalue of bottom left corner
                        vComptempMat(3)=l;%yvalue of bottom left corner
                        vComptempMat(4)=xEdges(apple+1);%xvalue of top right corner
                        vComptempMat(5)=min([l+yps,ymaxvec(n)]);%yvalue of tope right corner
                        vComptemp{1,n}=horzcat(vComptemp{1,n},vComptempMat);
%                         for k=xEdges(apple):xps:xEdges(apple+1)-xps
%                             vPlot(round(1+(l-ymin)/yps),round(1+(k-xmin)/xps))=voltn;
%                         end
                    end
                end
                
            end
        end
    end
    %The final value of vComptemp is a bunch of rectangles.  rectCompress
    %adds these together to make fewer, larger rectangles.  This makes
    %computation much faster as it scales with rectangle number.
    vComptemp{1,n}=rectCompress(vComptemp{1,n},xps,yps);
    if isfield(gates,gateNames{n})
        tempSubfield=getfield(gates,gateNames{n});
        tempSubfield.rects=[tempSubfield.rects,vComptemp{1,n}(2:5,:)];
        tempSubfield.polysX={tempSubfield.polysX{:}, polys{n,1}(:,1)};
        tempSubfield.polysY={tempSubfield.polysY{:}, polys{n,1}(:,2)};
        gates=setfield(gates,gateNames{n},tempSubfield);
    else
        tempSubfield.setVoltage=voltn;
        tempSubfield.z0=z0;
        tempSubfield.rects=vComptemp{1,n}(2:5,:);
        tempSubfield.polysX={polys{n,1}(:,1)};
        tempSubfield.polysY={polys{n,1}(:,2)};
        gates=setfield(gates,gateNames{n},tempSubfield);
        
    end
    
end
% vComp=horzcat(vComptemp{1,:});

end

