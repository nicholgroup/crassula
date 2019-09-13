%Crassula Quantum Dot Gate Simulator

%This simulates the potential from a pattern of gates on the surface
%of a material with a 2DEG.  It will then self consistently solve for the
%wavefunctions of multiple electrons by including the coloumb repulsion
%between them.  This portion was designed for few electron quantum dots.

%This is the main script for running a simulation.  In general, you should
%only have to change variables in this script and nothing in the functions
%themselves.


%% Input DXF Files

%This simulation uses gates geometries that are saved as DXF 2004 files.
%In order to improve computation efficiency, you typically want to break
%your gates up into two different files, one that is the fine gate features
%near the active region and another that has the larger coarse features.  The
%simulation runs each file with its own grid spacing.  This allows you to
%use a coarser graining for large feastures, speeding up computation.

%The DXF files should have the gates defined as closed lines.  It does not
%work for anything else.  It assums that the designs have a base unit of
%microns, meaning 1=1 um and .001=1 nm.  The layer of the object should be
%the gate name.  The names must have no spaces and must start with a
%letter.  Note that the name should be the same for features that
%will have the same voltage, even if they are in different DXF files.  The
%voltage on each gate should be saved as the z dimension.  Your simulation 
%will run fastest if you only use rectangles that are parallel to the x and 
%y axis.  Use diagonal lines only when necessary because the computation 
%time scales with the number of rectangels it grids into.  Also, remember 
%that features much smaller than the distance to the 2DEG will be quite 
%smeared so rounding should not have a huge effect on results but will make 
%computations much slower.


% filenameaccum='accumulationGates.dxf';
% filenamedep='depletionGates.dxf';%coarse features
% filenamecomp='siBox.dxf';

file='Si\SiGe_Q5.dxf';
filenamecomp='Si\SiGe_Q5Box.dxf';

files.gateFiles={file};
files.compBox=filenamecomp;

% filenamefine='QuadDotSplitAccum.dxf';
% filenamecomp='QuadDotSplitAccumBox.dxf';%the region where the potential at the 2DEF will be computed


% filenamefine='dummyDesign.dxf';
% filenamecomp='dummyBox.dxf';

% files.gateFiles={'2018_11_08_Si2DQD\\Si2DQD_L1.dxf','2018_11_08_Si2DQD\\Si2DQD_L2.dxf','2018_11_08_Si2DQD\\Si2DQD_L3.dxf'};%can be as long as you want.  Put comp file last!
% files.compBox='2018_11_08_Si2DQD\\Box_sm.dxf';
%files={filenamefine,filenamecomp};%can be as long as you want.

% Load voltages from saved
%It is inconvenient to have to adjust the DXF every time you want to save
%some tuning of the qubit.  If you have run your simulation before and
%saved a file, enter that here.  Otherwise leave it empty.

%saveFile='123.mat';
% files.saveFile='dummySave.mat';
files.saveFile='SiGeQ5';%If you don't have one
%files.saveFile='Si_DD.mat';
% files.saveFile='siSave.mat';





%% Computation Parameters

%This program works by turning DXF files into a set of rectangles which are
%then used to compute the potential in the 2DEG.  The smaller the grid size
%is, the more accurately it will render the design.  However, this will
%also make computations slower.  psfine and pscoarse allow you to have the
%features that are further from the region of interest coarser grained.
%This makes computation faster.  vGrid is the grid point size for where the
%potential is computed.  Smaller numbers are more precise, but slower.  The
%parameters below tend to work quite well for me.

p1=.005;
compParams.vGrid=.005;
compParams.rectGrid=[p1];
compParams.unitScale=10^-6;%this is for converting the dxf units to real units.  converts a micron to meters.


%% Material and Physics Parameters
physParams.m=.2*9.109*10^-31;%effective mass of electron in kg
physParams.hbar=1.05468*10^-34;%reduced Plancks constant in SI unites
physParams.q=-1.602*10^-19;%electron charge in C
physParams.EF=.2*physParams.q;%fermi level. estimated by turn on voltage of HB
physParams.epsilon=11.7*8.854*10^-12;%permitivity

z1=.07;%depth of the 2DEG from the surface.  Note-1=1um.
physParams.z0s=[z1];%should be seperated by commas

% fineParams=[z0, m, hbar, q, EF, epsilon];

% physParams={fineParams};%jsut need one if all layers have the same parameters
%physParams={rineParams, coarseParams, etc};%make each file have its own
%paramters like fineParams above.  Need a params for each file.  Should
%seperate with commas.



%% Opts
%Different computers benefit from either using a parallel for loop or doing
%the computation on the GPU.  Run this with gpuSwitch=0 the first time.  It
%test which mode is better for you.  Make sure you start your parallel pool
%first so it is a fair comparison.
%0=test, 1=gpu, 2=parallel for
opts.gpuSwitch=2;

%Can turn off plotting rectangular version of gates.  Should be on the
%first time to make sure the gridding worked how you want but you can turn
%it off to save time later.
opts.plotRects=0;

%plots the voltage from each gate independently.
opts.indGatePlot=0;

%% Simulation
%Change nothing here

[gates,newSaveFile]=crassula(files,compParams,physParams,opts);

%% Pull out the potential
load('SiGeQ5.mat');
V=voltPlot2DEG( gates, compParams);
D=densityPlot2DEG(V, compParams,physParams );
P=laplaceSolver(D,compParams,physParams);
figure(222); clf; imagesc(-P/1.6e-19);

maxIter=5;
V0=V;
for i=1:maxIter
    Dold=D;
    V=V0+P/abs(physParams.q);
    D=densityPlot2DEG(V, compParams,physParams);
    
    tt=Dold-D;
    figure(444); clf; imagesc(tt);
    colorbar
    max(abs(tt(:)))
    P=laplaceSolver(D,compParams,physParams);
    figure(332); clf; imagesc(P); title('electron potential(cm^{-2}'); colorbar;
    
    figure(333); clf; imagesc(D); title('electron density (cm^{-2}'); colorbar;
    figure(334); clf; imagesc(V); title('Potentital (V)'); colorbar;
    
    Dold=D;
    drawnow;
end

col=572;
row=613;

figure(111); clf; plot(-V(row,:)); xlabel('column');
xslice=-V(row,col-10:col+10);
figure(112); clf; plot(-V(:,col)); xlabel('row');
yslice=-V(row-10:row+10,col);

figure(113); clf; plot(xslice);
figure(114); clf; plot(yslice);

xvals=linspace(1,length(xslice),length(xslice));

xfit=polyfit(xvals,xslice,2);
yfit=polyfit(xvals,yslice',2);

xfit(1)/yfit(1)


