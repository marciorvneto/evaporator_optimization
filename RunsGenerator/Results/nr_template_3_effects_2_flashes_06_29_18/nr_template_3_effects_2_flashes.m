addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');

%% Defining blocks
E1 = Evaporator(1.6,973.522242261,'EFFECT-2');
E0 = Evaporator(1.2,973.522242261,'EFFECT-1');
E2 = Evaporator(2.0,973.522242261,'EFFECT-3');
F1 = Flash('FLASH-1');
F2 = Flash('FLASH-2');
VMix3 = VMixer('MIX-3');
VMix2 = VMixer('MIX-2');
%% Defining streams
L_2_1 = LiquidStream('BLSTREAM-10','BLIQ');
F = LiquidStream('BLSTREAM-11','BLIQ');
Lout = LiquidStream('BLSTREAM-12','BLIQ');
L_1_0 = LiquidStream('BLSTREAM-13','BLIQ');
C1 = CondensateStream('CSTREAM-15','COND');
CF1 = CondensateStream('CSTREAM-16','COND');
C0 = CondensateStream('CSTREAM-17','COND');
C2 = CondensateStream('CSTREAM-18','COND');
CF2 = CondensateStream('CSTREAM-19','COND');
V_F1_VMix2 = VaporStream('VSTREAM-17','VAPO');
Vout = VaporStream('VSTREAM-18','VAPO');
V_F2_VMix3 = VaporStream('VSTREAM-19','VAPO');
S = VaporStream('VSTREAM-20','VAPO');
V_VMix2_E1 = VaporStream('VSTREAM-21','VAPO');
V_E0_VMix2 = VaporStream('VSTREAM-22','VAPO');
V_VMix3_E2 = VaporStream('VSTREAM-23','VAPO');
V_E1_VMix3 = VaporStream('VSTREAM-24','VAPO');
%% Creating a handler for blocks and streams
handler = Handler();
%% Including blocks
handler.addBlock(E1);
handler.addBlock(VMix3);
handler.addBlock(F1);
handler.addBlock(VMix2);
handler.addBlock(F2);
handler.addBlock(E2);
handler.addBlock(E0);
%% Including streams
handler.addStream(CF1);
handler.addStream(V_VMix3_E2);
handler.addStream(Lout);
handler.addStream(S);
handler.addStream(C0);
handler.addStream(V_E1_VMix3);
handler.addStream(L_1_0);
handler.addStream(V_VMix2_E1);
handler.addStream(V_F1_VMix2);
handler.addStream(C2);
handler.addStream(L_2_1);
handler.addStream(Vout);
handler.addStream(C1);
handler.addStream(V_E0_VMix2);
handler.addStream(CF2);
handler.addStream(F);
handler.addStream(V_F2_VMix3);
%% Connecting streams
handler.connectBlocks(E2,E1,L_2_1);
handler.connectInStream(E2,F);
handler.connectOutStream(E0,Lout);
handler.connectBlocks(E1,E0,L_1_0);
handler.connectBlocks(E1,F2,C1);
handler.connectOutStream(F1,CF1);
handler.connectBlocks(E0,F1,C0);
handler.connectOutStream(E2,C2);
handler.connectOutStream(F2,CF2);
handler.connectBlocks(F1,VMix2,V_F1_VMix2);
handler.connectOutStream(E2,Vout);
handler.connectBlocks(F2,VMix3,V_F2_VMix3);
handler.connectInStream(E0,S);
handler.connectBlocks(VMix2,E1,V_VMix2_E1);
handler.connectBlocks(E0,VMix2,V_E0_VMix2);
handler.connectBlocks(VMix3,E2,V_VMix3_E2);
handler.connectBlocks(E1,VMix3,V_E1_VMix3);
%% Creating the simulation engine
engine = Engine(handler);
engine.preallocateVariables(engine.handler);


%% Defining constants

E1.areaEqualTo = E0;
E2.areaEqualTo = E0;

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

Lout.x_dis = 0.5;
Lout.fixedX_Dis = true;

Vout.temperature = 60 + 273.16;
Vout.fixedTemperature = true;

%% Bounds

engine.QBounds = [1.32e3,50.2e3];
engine.ABounds = [258,5200];
engine.x_disBounds = [0.1,0.6];
engine.x_totBounds = [0.1,0.6];

[lb,ub] = engine.getBounds(engine.handler);



fun = @(x) engine.evaluateBalances(x,engine.handler);
