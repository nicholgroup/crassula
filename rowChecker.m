function [ newZones,  chargeMap, checkedPos] = rowChecker(currentCol, cols2Check, row, chargeMap, checkedPos)
% [ colC, colU, valCell, leftAndRightNotEqual ]( colUVal,colU,colC,valCell )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

notSame=[];

for q=cols2Check
    if min(chargeMap{row,currentCol}==chargeMap{row,q})
        for k=min(currentCol,q)+1:max(currentCol,q)-1
            chargeMap{row,k}=chargeMap{row,currentCol};
            checkedPos(row,k)=1;
        end
    else
        notSame=[notSame, q];
    end        
end

newZones=[];

for p=notSame
    if p>currentCol+1
        newZones=[newZones; currentCol, p];
    elseif p<currentCol-1
        newZones=[newZones; p, currentCol];
    end
end






if 0% old
colC=sort(colC);
left=colC(colC<colUVal);
leftAndRightNotEqual=1;
if isempty(left)
else
    nLeft=max(left);
    if min(valCell{colUVal,1}==valCell{nLeft,1})
        intermed=colU(colU<colUVal);
        intermed=intermed(intermed>nLeft);
        leftAndRightNotEqual=0;
        for k=intermed'
            valCell{k,1}=valCell{colUVal,1};
            colC=vertcat(colC,k);
            colU=colU(colU~=k);
        end
    end
end

right=colC(colC>colUVal);
if isempty(right)
else
    nRight=min(right);
    if min(valCell{colUVal,1}==valCell{nRight,1})
        intermed=colU(colU>colUVal);
        intermed=intermed(intermed<nRight);
        leftAndRightNotEqual=0;
        for k=intermed'
            valCell{k,1}=valCell{colUVal,1};
            colC=vertcat(colC,k);
            colU=colU(colU~=k);
        end
    end
end

colC=sort(vertcat(colC,colUVal));
colU=colU(colU~=colUVal);
end
end

