clear;
global BESTX BESTF ICALL PX PF

ifunc=input('Enter the function number (1<=ifunc<=6): ');
ngs=input('Enter the number of complexes (def: ngs=2): ');
nCores=7;
if isempty(ngs); ngs=2; end;

if ifunc==1;
% This is the Goldstein-Price Function
% Bound X1=[-2,2], X2=[-2,2]; Global Optimum: 3.0,(0.0,-1.0)
    func=@funcWrapper;
    funcAct=cell(1,nCores);
    for i=1:nCores
        funcAct{i}=@functn1;
    end
    bl=[-2 -2]; bu=[2 2]; x0=[1 1];
end;

if ifunc==2;
%  This is the Rosenbrock Function
    func=@functn2;
%  Bound: X1=[-5,5], X2=[-2,8]; Global Optimum: 0,(1,1)
    bl=[-5 -5]; bu=[5 5]; x0=[1 1];
end;

if ifunc==3;
%  This is the Six-hump Camelback Function.
    func=@functn3;
%  Bound: X1=[-5,5], X2=[-5,5]
%  True Optima: -1.03628453489877, (-0.08983,0.7126), (0.08983,-0.7126)
    bl=[-5 -2]; bu=[5 8]; x0=[-0.08983 0.7126];
end;

if ifunc==4;
%  This is the Rastrigin Function
    func=@functn4;
%  Bound: X1=[-1,1], X2=[-1,1]; Global Optimum: -2, (0,0)
    bl=[-1 -1]; bu=[1 1]; x0=[0 0];
end;

if ifunc==5;
    
%  This is the Griewank Function (2-D or 10-D)
    func=@functn5;
%  Bound: X(i)=[-600,600], for i=1,2,...,10
%  Global Optimum: 0, at origin
    bl=-600*ones(1,10); bu=600*ones(1,10); x0=zeros(1,10);
end;

if ifunc==6;
%  This is the Shekel Function; Bound: X(i)=[0,10], j=1,2,3,4
    func=@functn6;
%  Global Optimum:-10.5364098252,(4,4,4,4)
    bl=zeros(1,4); bu=10*ones(1,4); x0=[4 4 4 4];
end;

if ifunc==7;
%   This is the Hartman Function
    func=@functn7;
%   Bound: X(j)=[0,1], j=1,2,...,6;
%   Global Optimum:-3.322368011415515, (0.201,0.150,0.477,0.275,0.311,0.657)
    bl=zeros(1,6); bu=ones(1,6); x0=[0.201,0.150,0.477,0.275,0.311,0.657];
end;

maxn=100000;
kstop=100;
pcento=0.1;
peps=0.001;
iseed=-1;
iniflg=0;

[bestx,bestf] = sceua(x0,bl,bu,maxn,kstop,pcento,peps,ngs,iseed,iniflg,func,funcAct);

return;
