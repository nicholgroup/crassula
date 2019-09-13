function [ chargeMap, checkedPos ] = rowSearcher( chargeMap, gates, compParams, physParams, CSD, rowNum, colVals, rowVals, checkedPos)

rowVal=rowVals(rowNum);
colNums=1:length(colVals);
totalRows=length(rowVals);
totalCols=length(colVals);

% vGridx=compParams.vGrid;
% vGridy=compParams.vGrid;
% m=physParams.m;
% hbar=physParams.hbar;
% q=physParams.q;
% EF=physParams.EF;
% epsilon=physParams.epsilon;
% wellNumber=CSD.wellNumber;
% wellX=CSD.wellX;
% wellY=CSD.wellY;
x=CSD.x;
y=CSD.y;

fixedGates=rmfield(gates,CSD.firstGate.name);
fixedGates=rmfield(fixedGates,CSD.secondGate.name);
fixedGateNames=sort(fieldnames(fixedGates));
tempField=getfield(fixedGates,fixedGateNames{1});
vFineWoSG=zeros(size(tempField.unitVoltageMap,1),size(tempField.unitVoltageMap,2));

for j=1:size(fixedGateNames,1)
    tempField=getfield(fixedGates,fixedGateNames{j});
    gateVoltageMap=tempField.unitVoltageMap*tempField.setVoltage;
    vFineWoSG=vFineWoSG+gateVoltageMap;
end

tempField=getfield(gates,CSD.firstGate.name);
vFineG1=tempField.unitVoltageMap;
tempField=getfield(gates,CSD.secondGate.name);
vFineG2=tempField.unitVoltageMap;

precheckCols=sort(colNums(checkedPos(rowNum,:)==1));

if ~checkedPos(rowNum,1)
%         valAtPoint=evalAtPoint(rowVal,colVals(1), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, 1);
    valAtPoint=evalAtPoint(rowVal,colVals(1), vFineG1, vFineG2, vFineWoSG, x, y, compParams, physParams);
    checkedPos(rowNum,1)=1;
    chargeMap{rowNum,1}=valAtPoint;
%     if ~isempty(precheckCols)
%         [ newZones,  chargeMap, checkedPos]=rowChecker(1, min(precheckCols), rowNum, chargeMap, checkedPos);
%     end
end

if ~checkedPos(rowNum,totalCols)
    valAtPoint=evalAtPoint(rowVal,colVals(totalCols), vFineG1, vFineG2, vFineWoSG, x, y, compParams, physParams);
%     valAtPoint=evalAtPoint(rowVal,colVals(totalCols), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, totalCols);
    checkedPos(rowNum,totalCols)=1;
    chargeMap{rowNum,totalCols}=valAtPoint;
%     rowChecker(totalCols, [1, max(precheckCols)], rowNum, chargeMap, checkedPos)
end

if isempty(precheckCols)
    colZonesTemp=[1 totalCols];
else
    colZonesTemp=[1];
    for checkDumb=precheckCols
        colZonesTemp(end,2)=checkDumb;
        colZonesTemp(end+1,1)=checkDumb;
    end
    colZonesTemp(end,2)=totalCols;
end

colZonesRem=[];

for p=1:size(colZonesTemp,1)
    if ~(colZonesTemp(p,1)+1==colZonesTemp(p,2))
        colZonesRem=[colZonesRem;colZonesTemp(p,:)];
    end
end

colZones=[];

for p=1:size(colZonesRem,1)
    [ newZones,  chargeMap, checkedPos] = rowChecker(colZonesRem(p,1), colZonesRem(p,2), rowNum, chargeMap, checkedPos);
    colZones=[colZones;newZones];
end


while size(colZones,1)>0
    currentCol=round((colZones(1,1)+colZones(1,2))/2);
%     valAtPoint=evalAtPoint(rowVal,colVals(currentCol), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colNums(currentCol));
    valAtPoint=evalAtPoint(rowVal,colVals(currentCol), vFineG1, vFineG2, vFineWoSG, x, y, compParams, physParams);
    checkedPos(rowNum,currentCol)=1;
    chargeMap{rowNum,currentCol}=valAtPoint;
    cols2Check=colZones(1,:);
    [ newZones,  chargeMap, checkedPos] = rowChecker(currentCol, cols2Check, rowNum, chargeMap, checkedPos);
    colZones(1,:)=[];
    colZones=[colZones; newZones];
end



if 0 %old
numOfCol=length(colNums);

if isempty(chargeMap{rowNum,2})
    valCell=cell(numOfCol,1);
    
    valAtPoint=evalAtPoint(rowVal,colVals(colNums(1)), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colNums(1));
    valCell{colNums(1),1}=valAtPoint;
    colC=colNums(1);
    colU=colNums(colNums~=colNums(1));
    
    valAtPoint=evalAtPoint(rowVal,colVals(colNums(end)), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colNums(end));
    valCell{colNums(end),1}=valAtPoint;
    [ colC, colU, valCell, leftAndRightNotEqual ] = rowChecker( colNums(end),colU,colC,valCell );
else
    valCell=cell(numOfCol,1);
    colC=chargeMap{rowNum,2};
%     [colC, order]=sort(colC);
    valsAlready=chargeMap{rowNum,3};
%     valsAlready=valsAlready(order);
    
    colU=colNums;
    
    counter=1;
    for j=colC'
        colU=colU(colU~=j);
        valCell{j,1}=valsAlready{counter,1};
        counter=counter+1;
    end
    uncheckedCol=length(colU);
    if uncheckedCol>0
        valAtPoint=evalAtPoint(rowVal,colVals(colU(1)), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colU(1));
        valCell{colU(1),1}=valAtPoint;
        [ colC, colU, valCell, leftAndRightNotEqual ] = rowChecker( colU(1),colU,colC,valCell );
    end
    uncheckedCol=length(colU);
    if uncheckedCol>0
        valAtPoint=evalAtPoint(rowVal,colVals(colU(end)), vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colU(end));
        valCell{colU(end),1}=valAtPoint;
        [ colC, colU, valCell, leftAndRightNotEqual ] = rowChecker( colU(end),colU,colC,valCell );
    end
end

leftAndRightNotEqual=0;

uncheckedCol=length(colU);
while uncheckedCol>0
    if leftAndRightNotEqual==1
        midNum=ceil(3*uncheckedCol/4);
        valAtPoint=evalAtPoint(rowVal,colVals(colU(midNum)),vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colU(midNum));
        valCell{colU(midNum),1}=valAtPoint;
        midNumNext=ceil(uncheckedCol/4);
        [ colC, colU, valCell, leftAndRightNotEqual ] = rowChecker( colU(midNum),colU,colC,valCell );
        uncheckedCol=length(colU);
        leftAndRightNotEqual=2;
        midNum=midNumNext;
    elseif leftAndRightNotEqual==2
        valAtPoint=evalAtPoint(rowVal,colVals(colU(midNum)),vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colU(midNum));
        valCell{colU(midNum),1}=valAtPoint;
        [ colC, colU, valCell, leftAndRightNotEqual ] = rowChecker( colU(midNum),colU,colC,valCell );
        uncheckedCol=length(colU);
    elseif leftAndRightNotEqual==0
        midNum=ceil(uncheckedCol/2);
        valAtPoint=evalAtPoint(rowVal,colVals(colU(midNum)),vFineG1, vFineG2, vFineWoSG, vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY,x,y, totalRows, totalCols, rowNum, colU(midNum));
        valCell{colU(midNum),1}=valAtPoint;
        [ colC, colU, valCell, leftAndRightNotEqual ] = rowChecker( colU(midNum),colU,colC,valCell );
        uncheckedCol=length(colU);
    end
end

colC=sort(colC);

chargeMap{rowNum,1}=rowNum;
chargeMap{rowNum,2}=colC;
chargeMap{rowNum,3}=valCell;
end
end

