function [ chargeMap, checkedPos, newZones] = colChecker( chargeMap, colNums, row, rows2Check, checkedPos )
% (rowUVal,rowU,rowC,colNums,chargeMap)
%[ rowU, rowC, chargeMap, aboveAndBelowNotEqual ]
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

for i=rows2Check
    for j=colNums'
        if min(chargeMap{row,j}==chargeMap{i,j})
            for k=min(row,i)+1:max(row,i)-1
                chargeMap{k,j}=chargeMap{row,j};
                checkedPos(k,j)=1;
            end
        end
    end
end

newZones=[];
for i=rows2Check
    if i>row+1
        newZones=[newZones; row, i];
    elseif i<row-1
        newZones=[newZones; i, row];
    end
end


if 0 %old
rowC=sort(rowC);
below=rowC(rowC<rowUVal);
aboveAndBelowNotEqual=1;
if isempty(below)
else
    nBelow=max(below);
    for j=colNums'
        if min(chargeMap{rowUVal,3}{j,1}==chargeMap{nBelow,3}{j,1})
            intermed=rowU(rowU<rowUVal);
            intermed=intermed(intermed>nBelow);
            aboveAndBelowNotEqual=0;
            for k=intermed'
%                 need to figure out how to not get it to add if the val
%                 already in
%                   check if column number is in the column list already
                if sum(chargeMap{k,2}==j)
                else
                    chargeMap{k,3}=vertcat(chargeMap{k,3},{chargeMap{nBelow,3}{j,1}});
                    chargeMap{k,2}=vertcat(chargeMap{k,2},j);
%                 rowC=vertcat(rowC,k);
%                 rowU=rowU(rowU~=k);
                end
            end
        end
    end
end

above=rowC(rowC>rowUVal);
if isempty(above)
else
    nAbove=min(above);
    for j=colNums'
        if min(chargeMap{rowUVal,3}{j,1}==chargeMap{nAbove,3}{j,1})
            intermed=rowU(rowU>rowUVal);
            intermed=intermed(intermed<nAbove);
            aboveAndBelowNotEqual=0;
            for k=intermed'
%                 chargeMap{k,3}{j,1}=chargeMap{nAbove,3}{j,1};
%                 chargeMap{k,2}=vertcat(chargeMap{k,3},j);
                if sum(chargeMap{k,2}==j)
                else
                    chargeMap{k,3}=vertcat(chargeMap{k,3},{chargeMap{nAbove,3}{j,1}});
                    chargeMap{k,2}=vertcat(chargeMap{k,2},j);
%                 rowC=vertcat(rowC,k);
%                 rowU=rowU(rowU~=k);
                end
            end
        end
    end
end

rowC=sort(vertcat(rowC,rowUVal));
rowU=rowU(rowU~=rowUVal);
end
end

