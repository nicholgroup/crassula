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


%filenameaccum='accumulationGates.dxf';
%Good one
% filenamedep='GaAs Quad\\gaAs_quad_v2_sim.dxf';%coarse features
% filenamecomp='GaAs Quad\\GaAsQuadBox.dxf';
% %files.saveFile={};%If you don't have one
% files.saveFile='GaAsQuad_V2.mat';
 
% filenamedep='GaAs Quad\\GaAsQuadLineGates2.dxf';%coarse features
% filenamecomp='GaAs Quad\\GaAsQuadLineBox.dxf';
%files.saveFile='GaAsQuadLine.mat';
%files.saveFile={};%If you don't have one

% filenamedep='GaAs Quad\\GaAsQuadLineGatesNoCan.dxf';%coarse features
% filenamecomp='GaAs Quad\\GaAsQuadLineBox.dxf';
% files.saveFile='GaAsQuadLineNoCan.mat';
%files.saveFile={};%If you don't have one

% filenamedep='GaAs Quad\\GaAsHarvard.dxf';%coarse features
% filenamecomp='GaAs Quad\\GaAsHarvardBox.dxf';
% files.saveFile='GaAsHarvard.mat';
% % files.saveFile={};%If you don't have one

%Good one 
filenamedep='GaAs Quad\\GaAsQuad4.dxf';%coarse features
filenamecomp='GaAs Quad\\GaAsQuad4Box.dxf';
files.saveFile='GaAsQuad4.mat';
%files.saveFile={};%If you don't have one



% filenamefine='QuadDotSplitAccum.dxf';
% filenamecomp='QuadDotSplitAccumBox.dxf';%the region where the potential at the 2DEF will be computed


% filenamefine='dummyDesign.dxf';
% filenamecomp='dummyBox.dxf';

files.gateFiles={filenamedep};%can be as long as you want.  Put comp file last!
files.compBox=filenamecomp;
%files={filenamefine,filenamecomp};%can be as long as you want.

% Load voltages from saved
%It is inconvenient to have to adjust the DXF every time you want to save
%some tuning of the qubit.  If you have run your simulation before and
%saved a file, enter that here.  Otherwise leave it empty.

%saveFile='123.mat';
% files.saveFile='dummySave.mat';
 %files.saveFile={};%If you don't have one
%files.saveFile='GaAsQuadLine.mat';
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

psaccum=.005;
psdep=.005;
compParams.vGrid=.01;
compParams.rectGrid=[psaccum, psdep];
compParams.unitScale=10^-6;%this is for converting the dxf units to real units.  converts a micron to meters.


%% Material and Physics Parameters
physParams.m=.067*9.109*10^-31;%effective mass of electron in kg
physParams.hbar=1.05468*10^-34;%reduced Plancks constant in SI units
physParams.q=-1.602*10^-19;%electron charge in C
physParams.EF=-.04*physParams.q;%fermi level. estimated by turn on voltage of HB
physParams.epsilon=12.9*8.854*10^-12;%permitivity

z0dep=.09;%depth of the 2DEG from the surface.  Note-1=1um.
physParams.z0s=[z0dep];%should be seperated by commas

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

%% save results to ppt
figs=[1,300, 1000];

for f=figs
    data=struct();
    data.slidetitle=filenamedep;
    data.comments='';
    data.body='';
    data.pptsavefile='C:\\Users\\Nichol\\Box Sync\\Nichol Group\\Crassula\\ppt\\GaAsQuadResults.pptx';
    
    fplot2ppt(f,[],data,struct());
end


