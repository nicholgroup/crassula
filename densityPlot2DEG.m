function [ densityMap ] = densityPlot2DEG( voltageMap,compParams, physParams )
%[ voltageMap ] = densityPlot2DEG( voltageMap,compParams, physParams )
%   Detailed explanation goes here
%Plots the voltage at the 2DEG

eps0=8.85e-12;
figure(300)
d=(voltageMap-physParams.EF/physParams.q).*1e11/.02;
d(d<0)=0;
densityMap=d;
h = pcolor(compParams.vXs,compParams.vYs,d);
set(h, 'EdgeColor', 'none')
colorbar;
title('Electron density (cm^{-2})')


end

