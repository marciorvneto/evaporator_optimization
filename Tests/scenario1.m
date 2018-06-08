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

E1.fixedA = true;
E2.fixedA = true;
E3.fixedA = true;

V0.temperature = 120+273.16;
V0.fixedTemperature = true;
V0.saturated = true;

L3.x_dis = 0.2;
L3.x_tot = 0.2;
L3.temperature = 70 +273.16;
L3.fixedTemperature = true;
L3.fixedX_Dis = true;
L3.fixedX_Tot = true;

L0.x_dis = 0.5;
L0.fixedX_Dis = true;

V1.temperature = 60 + 273.16;
V1.fixedTemperature = true;
V1.saturated = true;

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

[lb,ub] = engine.getBounds(engine.handler);

fun = @(x) engine.evaluateBalances(x,engine.handler);