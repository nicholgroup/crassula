function [ valAtPoint ] = evalAtPoint( rowVal, colVal, vFineG1, vFineG2, vFineWoSG, x,y, compParams, physParams)
%( rowVal, colVal, vFineG1, vFineG2, vFineWoSG,vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY, x,y, totalRows, totalCols, rowNum, colNum )
%UNTITLED9 Summary of this function goes here
V=vFineWoSG+rowVal*vFineG1+colVal*vFineG2;
% figure(600)
% subplot(totalRows,totalCols,(rowNum-1)*totalCols+colNum)
figure(600);
h=surf(V);
set(h,'EdgeColor', 'none');
vPsiComp=V(min([y(1),y(2)]):max([y(1),y(2)]),min([x(1), x(2)]):max([x(1),x(2)]));
display(['Gate 1 is ' num2str(rowVal) ' Gate 2 is ' num2str(colVal)])
[evalFinal, densityFinal, psiFinal, occupFinal] = densitySolverAtPoint(vPsiComp,compParams,physParams);%(vPsiComp,vGridx,vGridy, m, hbar, q, EF,epsilon, wellNumber,wellX,wellY);
valAtPoint=occupFinal{1,end};






%   Dummy test for rowSearcher
% if rowVal<5
%     if colVal<6
%         valAtPoint=[1 0];
%     else
%         valAtPoint=[0 1];
%     end
% elseif (rowVal>4) && (rowVal<6)
%     if colVal<6
%         valAtPoint=[0 2];
%     else
%         valAtPoint=[0 1];
%     end
% else
%     if colVal<6
%         valAtPoint=[0 2];
%     else
%         valAtPoint=[2 0];
%     end
% end
end

