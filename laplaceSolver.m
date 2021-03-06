function [u] = laplaceSolver(densityMap, compParams, physParams)
% [ voltageMap ] = voltPlot2DEG( gates, compParams, opts )
% Solves Laplace's equation in 2D to extrat the potential from the charge
% density. 
% 
% Adapted from https://www.mathworks.com/matlabcentral/fileexchange/38091-2d-laplace-equation

%Specifying parameters
nx=length(compParams.vXs);                          %Number of steps in space(x)
ny=length(compParams.vYs);                          %Number of steps in space(y)       
dx=compParams.vGrid.*compParams.unitScale;                     %Width of space step(x)
dy=compParams.vGrid.*compParams.unitScale;                     %Width of space step(y)
x=compParams.vXs;                        %Range of x(0,2) and specifying the grid points
y=compParams.vYs;                        %Range of y(0,2) and specifying the grid points
UW=0;                            %x=0 Dirichlet B.C 
UE=y.*0;                            %x=L Dirichlet B.C 
US=0;                            %y=0 Dirichlet B.C 
UN=0;                            %y=L Dirichlet B.C 
UnW=0;                           %x=0 Neumann B.C (du/dn=UnW)
UnE=0;                           %x=L Neumann B.C (du/dn=UnE)
UnS=0;                           %y=0 Neumann B.C (du/dn=UnS)
UnN=0;                      
u=zeros(nx,ny);                  %Pre-allocating u


%B.C vector
bc=zeros(nx-2,ny-2);
bc(1,:)=UW/dx^2; bc(nx-2,:)=UE(2:ny-1)/dx^2;  %Dirichlet B.Cs
%bc(:,1)=US/dy^2; bc(:,ny-2)=UN/dy^2;  %Dirichlet B.Cs
%bc(1,:)=-UnW/dx; bc(nx-2,:)=UnE/dx;  %Neumann B.Cs
bc(:,1)=-UnS/dy; bc(:,ny-2)=UnN/dy;  %Neumann B.Cs
%B.Cs at the corners:
bc(1,1)=UW/dx^2-UnS/dy; bc(nx-2,1)=UE(2)/dx^2-UnS/dy;
bc(1,ny-2)=UW/dx^2+UnN/dy; bc(nx-2,ny-2)=UE(ny-1)/dx^2+UnN/dy;

%Calculating the coefficient matrix for the implicit scheme
Ex=sparse(2:nx-2,1:nx-3,1,nx-2,nx-2);
Ax=Ex+Ex'-2*speye(nx-2);        %Dirichlet B.Cs
%Ax(1,1)=-1; Ax(nx-2,nx-2)=-1;  %Neumann B.Cs
Ey=sparse(2:ny-2,1:ny-3,1,ny-2,ny-2);
Ay=Ey+Ey'-2*speye(ny-2);        %Dirichlet B.Cs
Ay(1,1)=-1; Ay(ny-2,ny-2)=-1;  %Neumann B.Cs
A=kron(Ay/dy^2,speye(nx-2))+kron(speye(ny-2),Ax/dx^2);


q=densityMap.*1e4.*dx.*dy.*abs(physParams.q); %charge at each grid point. 1e4 converst to m^-2;
S=q/physParams.epsilon;
S=S(2:end-1,2:end-1);
% S=zeros(nx-2,ny-2);             %Source term
% S(50:60,50:60)=100;
S=reshape(S-bc,[],1);
S=A\S;
S=reshape(S,nx-2,ny-2);
u(2:nx-1,2:ny-1)=S;
%Boundary conditions
%Dirichlet:
u(1,:)=UW;
u(nx,:)=UE;
u(:,1)=US;
u(:,ny)=UN;
end

