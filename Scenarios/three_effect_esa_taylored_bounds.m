addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');

%% Block definitions

E1 = Evaporator(1.2,1040,'E1');
E2 = Evaporator(1.6,1040,'E2');
E3 = Evaporator(2.0,1040,'E3');

V0 = VaporStream('V0','VAPO');
V1 = VaporStream('V1','VAPO');
V2 = VaporStream('V2','VAPO');
V3 = VaporStream('V3','VAPO');

L0 = LiquidStream('L0','BLIQ');
L1 = LiquidStream('L1','BLIQ');
L2 = LiquidStream('L2','BLIQ');
L3 = LiquidStream('L3','BLIQ');

C1 = CondensateStream('C1','COND');
C2 = CondensateStream('C2','COND');
C3 = CondensateStream('C3','COND');

F1 = Flash('F1');
VMIX = VMixer('VMIX');
VMixOut = VaporStream('VMixOut','VAPO');
VFlash = VaporStream('VFlash','VAPO');
LFlash = CondensateStream('LFlash','BLIQ');

%% Input data

E2.areaEqualTo = E1;
E3.areaEqualTo = E1;

V0.temperature = 120+273.16;
V0.fixedTemperature = true;
V0.saturated = true;

L3.x_dis = 0.2;
L3.x_tot = 0.2;
L3.temperature = 40 +273.16;
L3.flow = 50;
L3.fixedTemperature = true;
L3.fixedX_Dis = true;
L3.fixedX_Tot = true;
L3.fixedFlow = true;

L0.x_dis = 0.5;
L0.fixedX_Dis = true;

V3.temperature = 60 + 273.16;
V3.fixedTemperature = true;
% V1.saturated = true;

%% Simulator setup

handler = Handler();

handler.addBlock(E1);
handler.addBlock(E2);
handler.addBlock(E3);

handler.addStream(V0);
handler.addStream(V1);
handler.addStream(V2);
handler.addStream(V3);

handler.addStream(L0);
handler.addStream(L1);
handler.addStream(L2);
handler.addStream(L3);

handler.addStream(C1);
handler.addStream(C2);
handler.addStream(C3);

% Flash

handler.addStream(VMixOut);
handler.addBlock(VMIX);
handler.addBlock(F1);
handler.addStream(VFlash);
handler.addStream(LFlash);

%% Connectivity

% Vapor

handler.connectInStream(E1,V0);
handler.connectBlocks(E1,E2,V1);
handler.connectBlocks(E2,VMIX,V2);
handler.connectBlocks(VMIX,E3,VMixOut);
handler.connectOutStream(E3,V3);

% Black Liquor

handler.connectOutStream(E1,L0);
handler.connectBlocks(E2,E1,L1);
handler.connectBlocks(E3,E2,L2);
handler.connectInStream(E3,L3);

% Condensate

handler.connectOutStream(E1,C1);
handler.connectOutStream(E2,C2);
handler.connectOutStream(E3,C3);

% Flash

handler.connectInStream(F1,C2);
handler.connectBlocks(F1,VMIX,VFlash);
handler.connectOutStream(F1,LFlash);

%% Engine setup

engine = Engine(handler);
engine.preallocateVariables(engine.handler);

xCMAES = [3.931600e+02	1.291179e+01	1.987283e+02	3.658396e+02	1.136251e+01	5.751884e+01	3.471837e+02	1.009098e+01	3.226259e+01	3.331600e+02	8.546535e+00	1.828341e+01	3.658396e+02	1.999998e+01	5.000004e-01	5.000001e-01	3.471837e+02	3.136249e+01	3.188522e-01	3.188520e-01	3.331600e+02	4.145346e+01	2.412343e-01	2.412342e-01	3.131600e+02	5.000000e+01	2.000000e-01	1.999999e-01	3.931600e+02	1.291179e+01	1.987283e+02	3.579959e+02	1.136251e+01	5.751877e+01	3.439258e+02	1.037637e+01	3.226248e+01	3.470963e+02	1.037637e+01	3.226254e+01	3.439259e+02	2.853953e-01	3.226257e+01	3.439259e+02	1.107711e+01	7.948367e+02	8.715090e+02	2.857201e+04	8.715089e+02	2.601402e+04	8.715091e+02	2.429130e+04
]';

lb = xCMAES * 0.9;
ub = xCMAES * 1.1;

fun = @(x) engine.evaluateBalances(x,engine.handler);
