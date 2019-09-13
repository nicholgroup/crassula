    
figure(600)
CSD.voltStep=.01;
dot1=1;
dot2=2;
rowVals=[1;2;3];
colVals=[4;5;6];

wellOccupPlot{1,1}=[0, 1, 2; 0, 1, 2; 0, 1, 2];
wellOccupPlot{1,2}=[2, 2, 2; 1, 1, 1; 0, 0, 0];

dot1Max=max(max(wellOccupPlot{1,dot1}));
dot2Max=max(max(wellOccupPlot{1,dot2}));

dot1Min=min(min(wellOccupPlot{1,dot1}));
dot2Min=min(min(wellOccupPlot{1,dot2}));

subplot(1,2,2); hold on
for i=rowVals'
        for j=colVals'
            xVolt=[i+CSD.voltStep/2; i+CSD.voltStep/2; i-CSD.voltStep/2; i-CSD.voltStep/2];
            yVolt=[j+CSD.voltStep/2; j-CSD.voltStep/2; j-CSD.voltStep/2; j+CSD.voltStep/2];
            
            colorDot1=1-(wellOccupPlot{1,dot1}(i,j)-dot1Min)/(dot1Max-dot1Min);
            colorDot2=1-(wellOccupPlot{1,dot2}(i,j)-dot2Min)/(dot2Max-dot2Min);;
            
            fillColor=[colorDot1 1 colorDot2];
            
            fill(xVolt, yVolt, fillColor);
            
        end
    end