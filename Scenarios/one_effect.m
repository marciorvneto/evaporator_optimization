clear all, close all, clc

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

[lb,ub] = engine.getBounds(engine.handler);

fun = @(x) engine.evaluateBalances(x,engine.handler);

opts = [];
opts.LBounds = lb;
opts.UBounds = ub;
opts.Restarts = 0;
opts.PopSize = 100;
opts.LogPlot = true;

[XMIN, FMIN, COUNTEVAL, STOPFLAG, OUT, BESTEVER] = cmaes('fobj', (lb+ub)/2, 0.5*(ub-lb),opts,engine);