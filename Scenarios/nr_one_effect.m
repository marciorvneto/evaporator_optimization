addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');

%% Block definitions

E = Evaporator(1.2,1040,'E');

S = VaporStream('S','VAPO');
V = VaporStream('V','VAPO');

F = LiquidStream('F','BLIQ');
L = LiquidStream('L','BLIQ');

C = CondensateStream('C','COND');


%% Input data

% E.fixedA = true;

S.temperature = 120 + 273.16;
S.fixedTemperature = true;
% S.temperature = 120;
% S.fixedPressure = true;
S.saturated = true;

F.flow = 50;
F.x_dis = 0.2;
F.x_tot = 0.2;
F.temperature = 40 + 273.16;
F.fixedTemperature = true;
F.fixedFlow = true;
F.fixedX_Dis = true;
F.fixedX_Tot = true;

L.x_dis = 0.5;
L.fixedX_Dis = true;

V.temperature = 60 + 273.16;
V.fixedTemperature = true;
% V.saturated = true;

%% Simulator setup

handler = Handler();

handler.addBlock(E);


handler.addStream(S);
handler.addStream(V);


handler.addStream(F);
handler.addStream(L);

handler.addStream(C);


%% Connectivity

% Vapor

handler.connectInStream(E,S);
handler.connectOutStream(E,V);

% Black Liquor

handler.connectOutStream(E,L);
handler.connectInStream(E,F);

% Condensate

handler.connectOutStream(E,C);

%% Engine setup

engine = Engine(handler);
engine.preallocateVariables(engine.handler);

engine.QBounds = [50.32e3,100.2e3];
engine.ABounds = [258,5200];
engine.x_disBounds = [0.1,0.6];
engine.x_totBounds = [0.1,0.6];

[lb,ub] = engine.getBounds(engine.handler);
% 
% xsol = [3.931600000000000e+02
%      3.439235289419030e+01
%      1.987283234714000e+02
%      3.331600000000000e+02
%      3.000000000000000e+01
%      1.485922648867641e+01
%      3.131600000000000e+02
%      5.000000000000000e+01
%      2.000000000000000e-01
%      2.000000000000000e-01
%      3.331600000000000e+02
%      2.000000000000000e+01
%      5.000000000000000e-01
%      5.000000000000000e-01
%      3.931600000000000e+02
%      3.439235289419030e+01
%      1.987283234714000e+02
%      1.057021037931789e+03
%      7.610551473108878e+04];
% 
% lb = [3.538440000000001e+02
%      3.095311760477127e+01
%      1.788554911242600e+02
%      2.998440000000001e+02
%      2.700000000000000e+01
%      1.337330383980877e+01
%      2.818440000000001e+02
%      4.500000000000000e+01
%      1.800000000000000e-01
%      1.800000000000000e-01
%      2.998440000000001e+02
%      1.800000000000000e+01
%      4.500000000000000e-01
%      4.500000000000000e-01
%      3.538440000000001e+02
%      3.095311760477127e+01
%      1.788554911242600e+02
%      9.513189341386099e+02
%      6.849496325797991e+04];
% 
% ub = [4.324760000000001e+02
%      3.783158818360933e+01
%      2.186011558185400e+02
%      3.664760000000001e+02
%      3.300000000000000e+01
%      1.634514913754405e+01
%      3.444760000000001e+02
%      5.500000000000001e+01
%      2.200000000000000e-01
%      2.200000000000000e-01
%      3.664760000000001e+02
%      2.200000000000000e+01
%      5.500000000000000e-01
%      5.500000000000000e-01
%      4.324760000000001e+02
%      3.783158818360933e+01
%      2.186011558185400e+02
%      1.162723141724968e+03
%      8.371606620419768e+04];
%  
%  lb = xsol*0.5;
%  ub = xsol*1.5;


fun = @(x) engine.evaluateBalances(x,engine.handler);

opts = [];
opts.LBounds = lb;
opts.UBounds = ub;
opts.Restarts = 0;
opts.PopSize = 100;
opts.LogPlot = true;

% [XMIN, FMIN, COUNTEVAL, STOPFLAG, OUT, BESTEVER] = cmaes('fobj', (lb+ub)/2, 0.5*(ub-lb),opts,engine);