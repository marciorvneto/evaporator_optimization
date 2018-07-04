addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');

%% Defining blocks
E1 = Evaporator(1.6,1000.0,'EVAP-1');
E0 = Evaporator(2.0,1000.0,'EVAP-0');
E3 = Evaporator(1.2,1000.0,'EVAP-3');
E2 = Evaporator(1.2,1000.0,'EVAP-2');
F1 = Flash('FLASH-1');
F0 = Flash('FLASH-0');
LMix1 = LMixer('MIX-1');
VMix0 = VMixer('MIX-0');
VMix3 = VMixer('MIX-3');
VMix4 = VMixer('MIX-4');
LSpl1 = LSplitter('SPL-1');
VSpl0 = VSplitter('SPL-0');
%% Defining streams
L1 = LiquidStream('BLSTREAM-16','BLIQ');
L0 = LiquidStream('BLSTREAM-17','BLIQ');
L3 = LiquidStream('BLSTREAM-18','BLIQ');
L2 = LiquidStream('BLSTREAM-19','BLIQ');
L5 = LiquidStream('BLSTREAM-20','BLIQ');
L4 = LiquidStream('BLSTREAM-21','BLIQ');
L7 = LiquidStream('BLSTREAM-22','BLIQ');
L6 = LiquidStream('BLSTREAM-23','BLIQ');
C1 = CondensateStream('CSTREAM-10','COND');
C0 = CondensateStream('CSTREAM-11','COND');
C3 = CondensateStream('CSTREAM-12','COND');
C2 = CondensateStream('CSTREAM-13','COND');
C9 = CondensateStream('CSTREAM-14','COND');
C8 = CondensateStream('CSTREAM-15','COND');
V11 = VaporStream('VSTREAM-24','VAPO');
V10 = VaporStream('VSTREAM-25','VAPO');
V1 = VaporStream('VSTREAM-26','VAPO');
V0 = VaporStream('VSTREAM-27','VAPO');
V3 = VaporStream('VSTREAM-28','VAPO');
V2 = VaporStream('VSTREAM-29','VAPO');
V5 = VaporStream('VSTREAM-30','VAPO');
V4 = VaporStream('VSTREAM-31','VAPO');
V7 = VaporStream('VSTREAM-32','VAPO');
V6 = VaporStream('VSTREAM-33','VAPO');
V9 = VaporStream('VSTREAM-34','VAPO');
V8 = VaporStream('VSTREAM-35','VAPO');
%% Creating a handler for blocks and streams
handler = Handler();
%% Including blocks
handler.addBlock(E0);
handler.addBlock(E2);
handler.addBlock(LSpl1);
handler.addBlock(E3);
handler.addBlock(VMix4);
handler.addBlock(LMix1);
handler.addBlock(VMix3);
handler.addBlock(VSpl0);
handler.addBlock(F0);
handler.addBlock(E1);
handler.addBlock(F1);
handler.addBlock(VMix0);
%% Including streams
handler.addStream(V2);
handler.addStream(L6);
handler.addStream(V5);
handler.addStream(C1);
handler.addStream(V4);
handler.addStream(C0);
handler.addStream(V7);
handler.addStream(C3);
handler.addStream(V6);
handler.addStream(C2);
handler.addStream(V9);
handler.addStream(C9);
handler.addStream(V8);
handler.addStream(C8);
handler.addStream(L1);
handler.addStream(L0);
handler.addStream(L3);
handler.addStream(V11);
handler.addStream(L2);
handler.addStream(V10);
handler.addStream(L5);
handler.addStream(V1);
handler.addStream(L4);
handler.addStream(V0);
handler.addStream(L7);
handler.addStream(V3);
%% Connecting streams
handler.connectBlocks(LSpl1,E3,L1);
handler.connectInStream(LSpl1,L0);
handler.connectBlocks(LSpl1,LMix1,L3);
handler.connectBlocks(E3,LMix1,L2);
handler.connectBlocks(E2,E1,L5);
handler.connectBlocks(LMix1,E2,L4);
handler.connectOutStream(E0,L7);
handler.connectBlocks(E1,E0,L6);
handler.connectBlocks(E0,F0,C1);
handler.connectBlocks(E1,F1,C0);
handler.connectOutStream(F1,C3);
handler.connectOutStream(F0,C2);
handler.connectOutStream(E3,C9);
handler.connectOutStream(E2,C8);
handler.connectBlocks(VSpl0,E3,V11);
handler.connectInStream(E0,V10);
handler.connectOutStream(VMix0,V1);
handler.connectBlocks(VSpl0,VMix0,V0);
handler.connectBlocks(E2,VSpl0,V3);
handler.connectBlocks(E3,VMix0,V2);
handler.connectBlocks(E1,VMix4,V5);
handler.connectBlocks(VMix4,E2,V4);
handler.connectBlocks(VMix3,E1,V7);
handler.connectBlocks(F1,VMix4,V6);
handler.connectBlocks(E0,VMix3,V9);
handler.connectBlocks(F0,VMix3,V8);
%% Creating the simulation engine
engine = Engine(handler);
engine.preallocateVariables(engine.handler);



%% Defining constants

E1.areaEqualTo = E0;
E2.areaEqualTo = E0;
% E3.areaEqualTo = E0;

V10.temperature = 120 + 273.16;
V10.fixedTemperature = true;
V10.saturated = true;

L0.flow = 50;
L0.x_dis = 0.2;
L0.x_tot = 0.2;
L0.temperature = 40 + 273.16;
L0.fixedTemperature = true;
L0.fixedFlow = true;
L0.fixedX_Dis = true;
L0.fixedX_Tot = true;

L7.x_dis = 0.5;
L7.fixedX_Dis = true;

V1.temperature = 60 + 273.16;
V1.fixedTemperature = true;
% V1.saturated = true;

%% Bounds

engine.QBounds = [7.32e3,73.2e3];
engine.ABounds = [458,7320];
engine.x_disBounds = [0.2,0.5];
engine.x_totBounds = [0.2,0.5];
engine.temperatureBounds = [40,120]+273.16;
engine.pressureBounds = [satP(engine.temperatureBounds(1),SteamCoefficients())
                         satP(engine.temperatureBounds(2),SteamCoefficients())]*1000;


addInfo = {};
addInfo.Vin = V10;
addInfo.Vout = V1;
addInfo.VSpl = VSpl0;
addInfo.LSpl = LSpl1;
addInfo.Evap = E0;

addInfo.VToNewEvap = V11;

engine.addInfo = addInfo;

[lb,ub] = engine.getBounds(engine.handler);

lb = [lb;0;0;60+273.16];
ub = [ub;1;1;100+273.16];



fun = @(x) engine.evaluateBalances(x,engine.handler);
