function [ chargeMap,rowVals,colVals ] = dotChargeMap(gates,CSD, compParams, physParams)
%old inputs below
%( v1min, v1max, v2min, v2max, vStep, vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y,v1BaseVal,v2BaseVal );

%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
% rowVals=v1BaseVal+[v1min:vStep:v1max]';
% colVals=v2BaseVal+[v2min:vStep:v2max]';

rowVals=linspace(CSD.firstGate.lowerVoltage,CSD.firstGate.upperVoltage,1+round((CSD.firstGate.upperVoltage-CSD.firstGate.lowerVoltage)/CSD.voltStep))';
colVals=linspace(CSD.secondGate.lowerVoltage,CSD.secondGate.upperVoltage,1+round((CSD.secondGate.upperVoltage-CSD.secondGate.lowerVoltage)/CSD.voltStep))';

rowNums=[1:1:length(rowVals)]';
colNums=[1:1:length(colVals)]';

checkedPos=zeros(length(rowVals),length(colVals));

chargeMap=cell(length(rowVals),length(colVals));

[chargeMap, checkedPos]=rowSearcher( chargeMap, gates, compParams, physParams, CSD, 1, colVals, rowVals, checkedPos);

[chargeMap, checkedPos]=rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowNums(end), colVals, rowVals, checkedPos);
% [ chargeMap, checkedPos] = colChecker( chargeMap, colNums, rowNums(end), 1, checkedPos );
[ chargeMap, checkedPos, rowZones] = colChecker( chargeMap, colNums, rowNums(end), 1, checkedPos );

while size(rowZones,1)>0
    currentRow=round((rowZones(1,1)+rowZones(1,2))/2);
    [chargeMap, checkedPos]=rowSearcher( chargeMap, gates, compParams, physParams, CSD, currentRow, colVals, rowVals, checkedPos);
    check=rowZones(1,:);
    [ chargeMap, checkedPos, newZones] = colChecker( chargeMap, colNums, currentRow, check, checkedPos );
    rowZones(1,:)=[];
    rowZones=[rowZones; newZones];
end



if 0  % old version
rowU=rowNums;

chargeMap=rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowU(1), colNums, rowVals(rowU(1)), colVals, rowNums(end),colNums(end) );
rowC=rowU(1);
rowU=rowU(rowU~=rowU(1));


chargeMap=rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowU(end), colNums, rowVals(rowU(end)), colVals, rowNums(end),colNums(end) );
[ rowU, rowC, chargeMap, aboveAndBelowNotEqual ] = colChecker( rowU(end),rowU,rowC,colNums,chargeMap );

aboveAndBelowNotEqual=0;

uncheckedRow=length(rowU);
while uncheckedRow>0
    if aboveAndBelowNotEqual==1
        midNum=ceil(3*uncheckedRow/4);
        chargeMap=rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowU(midNum), colNums, rowVals(rowU(midNum)), colVals, rowNums(end),colNums(end) );
        midNumNext=ceil(uncheckedRow/4);
        [ rowU, rowC, chargeMap, aboveAndBelowNotEqual ] = colChecker( rowU(midNum),rowU,rowC,colNums,chargeMap );
        aboveAndBelowNotEqual=2;
        midNum=midNumNext;
        uncheckedRow=length(rowU);
    elseif aboveAndBelowNotEqual==2
        chargeMap=rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowU(midNum), colNums, rowVals(rowU(midNum)), colVals, rowNums(end),colNums(end) );
        [ rowU, rowC, chargeMap, aboveAndBelowNotEqual ] = colChecker( rowU(midNum),rowU,rowC,colNums,chargeMap );
        uncheckedRow=length(rowU);
    elseif aboveAndBelowNotEqual==0
        midNum=ceil(uncheckedRow/2);
        chargeMap=rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowU(midNum), colNums, rowVals(rowU(midNum)), colVals, rowNums(end),colNums(end) );
        [ rowU, rowC, chargeMap, aboveAndBelowNotEqual ] = colChecker( rowU(midNum),rowU,rowC,colNums,chargeMap );
        uncheckedRow=length(rowU);
    end
end
end
end

