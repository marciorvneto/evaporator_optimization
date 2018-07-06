addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');

%% Defining blocks
E1 = Evaporator(1.2,1000.0,'EVAP-1');
E0 = Evaporator(1.2,1000.0,'EVAP-0');
ESER = Evaporator(1.2,1000.0,'SERIES');
E2 = Evaporator(1.2,1000.0,'EVAP-2');
EPAR = Evaporator(1.2,1000.0,'PARALLEL');
F1 = Flash('FLASH-1');
F0 = Flash('FLASH-0');
F2 = Flash('FLASH-2');
LMix1 = LMixer('MIX-1');
LMix0 = LMixer('MIX-0');
CMix3 = VMixer('MIX-3');
CMix3.condensate = true;
VMix2 = VMixer('MIX-2');
LMix5 = LMixer('MIX-5');
VMix4 = VMixer('MIX-4');
VMix7 = VMixer('MIX-7');
VMix6 = VMixer('MIX-6');
LSpl1 = LSplitter('SPL-1');
VSpl0 = VSplitter('SPL-0');
LSpl3 = LSplitter('SPL-3');
LSpl2 = LSplitter('SPL-2');
VSpl4 = VSplitter('SPL-4');
%% Defining streams
F = LiquidStream('BLIN','BLIQ');
L10 = LiquidStream('BLSTREAM-10','BLIQ');
BLToSer = LiquidStream('SERBLIN','BLIQ');
L15 = LiquidStream('BLSTREAM-15','BLIQ');
L14 = LiquidStream('BLSTREAM-14','BLIQ');
L17 = LiquidStream('BLSTREAM-17','BLIQ');
L16 = LiquidStream('BLSTREAM-16','BLIQ');
Lout = LiquidStream('BLOUT','BLIQ');
BLToPar = LiquidStream('PARBLIN','BLIQ');
L0 = LiquidStream('BLSTREAM-0','BLIQ');
L5 = LiquidStream('BLSTREAM-5','BLIQ');
L4 = LiquidStream('BLSTREAM-4','BLIQ');
L7 = LiquidStream('BLSTREAM-7','BLIQ');
L9 = LiquidStream('BLSTREAM-9','BLIQ');
L8 = LiquidStream('BLSTREAM-8','BLIQ');
C1 = CondensateStream('CSTREAM-1','COND');
C0 = CondensateStream('CSTREAM-0','COND');
C3 = CondensateStream('CSTREAM-3','COND');
C2 = CondensateStream('CSTREAM-2','COND');
C5 = CondensateStream('CSTREAM-5','COND');
C4 = CondensateStream('CSTREAM-4','COND');
C7 = CondensateStream('CSTREAM-7','COND');
C6 = CondensateStream('CSTREAM-6','COND');
C8 = CondensateStream('CSTREAM-8','COND');
V11 = VaporStream('VSTREAM-11','VAPO');
V10 = VaporStream('VSTREAM-10','VAPO');
V15 = VaporStream('VSTREAM-15','VAPO');
V14 = VaporStream('VSTREAM-14','VAPO');
V17 = VaporStream('VSTREAM-17','VAPO');
V16 = VaporStream('VSTREAM-16','VAPO');
Vout = VaporStream('VOUT','VAPO');
V18 = VaporStream('SERVIN','VAPO');
V1 = VaporStream('PARVIN','VAPO');
S = VaporStream('VIN','VAPO');
V2 = VaporStream('VSTREAM-2','VAPO');
V5 = VaporStream('VSTREAM-5','VAPO');
V4 = VaporStream('VSTREAM-4','VAPO');
V7 = VaporStream('VSTREAM-7','VAPO');
V6 = VaporStream('VSTREAM-6','VAPO');
V9 = VaporStream('VSTREAM-9','VAPO');
V8 = VaporStream('VSTREAM-8','VAPO');
%% Creating a handler for blocks and streams
handler = Handler();
%% Including blocks
handler.addBlock(VSpl4);
handler.addBlock(LMix1);
handler.addBlock(LMix0);
handler.addBlock(LSpl2);
handler.addBlock(VMix7);
handler.addBlock(F1);
handler.addBlock(VSpl0);
handler.addBlock(EPAR);
handler.addBlock(VMix4);
handler.addBlock(LMix5);
handler.addBlock(F2);
handler.addBlock(VMix6);
handler.addBlock(ESER);
handler.addBlock(E2);
handler.addBlock(LSpl3);
handler.addBlock(E1);
handler.addBlock(E0);
handler.addBlock(CMix3);
handler.addBlock(LSpl1);
handler.addBlock(F0);
handler.addBlock(VMix2);
%% Including streams
handler.addStream(C1);
handler.addStream(V5);
handler.addStream(L14);
handler.addStream(C2);
handler.addStream(C3);
handler.addStream(V9);
handler.addStream(Lout);
handler.addStream(F);
handler.addStream(L17);
handler.addStream(V4);
handler.addStream(L9);
handler.addStream(V17);
handler.addStream(BLToSer);
handler.addStream(L0);
handler.addStream(V11);
handler.addStream(L8);
handler.addStream(C5);
handler.addStream(C8);
handler.addStream(V1);
handler.addStream(V14);
handler.addStream(V6);
handler.addStream(BLToPar);
handler.addStream(Vout);
handler.addStream(L10);
handler.addStream(C6);
handler.addStream(S);
handler.addStream(V16);
handler.addStream(C0);
handler.addStream(L15);
handler.addStream(L5);
handler.addStream(V10);
handler.addStream(V7);
handler.addStream(C7);
handler.addStream(C4);
handler.addStream(V18);
handler.addStream(V8);
handler.addStream(L7);
handler.addStream(V15);
handler.addStream(L4);
handler.addStream(V2);
handler.addStream(L16);
%% Connecting streams
handler.connectInStream(LSpl3,F);
handler.connectBlocks(LSpl2,LMix1,L10);
handler.connectBlocks(LSpl3,ESER,BLToSer);
handler.connectBlocks(LSpl3,LMix5,L15);
handler.connectBlocks(ESER,LMix5,L14);
handler.connectBlocks(E2,E1,L17);
handler.connectBlocks(LMix5,E2,L16);
handler.connectOutStream(LMix1,Lout);
handler.connectBlocks(LSpl1,EPAR,BLToPar);
handler.connectBlocks(E1,LSpl1,L0);
handler.connectBlocks(LMix0,E0,L5);
handler.connectBlocks(LSpl1,LMix0,L4);
handler.connectBlocks(E0,LMix1,L7);
handler.connectBlocks(LSpl2,LMix0,L9);
handler.connectBlocks(EPAR,LSpl2,L8);
handler.connectBlocks(EPAR,CMix3,C1);
handler.connectBlocks(E0,CMix3,C0);
handler.connectBlocks(E1,F1,C3);
handler.connectBlocks(CMix3,F0,C2);
handler.connectOutStream(ESER,C5);
handler.connectBlocks(E2,F2,C4);
handler.connectOutStream(F1,C7);
handler.connectOutStream(F2,C6);
handler.connectOutStream(F0,C8);
handler.connectBlocks(E2,VSpl4,V11);
handler.connectBlocks(VMix4,E2,V10);
handler.connectBlocks(ESER,VMix6,V15);
handler.connectBlocks(VSpl4,VMix6,V14);
handler.connectBlocks(VSpl4,VMix7,V17);
handler.connectBlocks(F2,VMix7,V16);
handler.connectOutStream(VMix6,Vout);
handler.connectBlocks(VMix7,ESER,V18);
handler.connectBlocks(VSpl0,EPAR,V1);
handler.connectInStream(VSpl0,S);
handler.connectBlocks(VSpl0,E0,V2);
handler.connectBlocks(E0,VMix2,V5);
handler.connectBlocks(EPAR,VMix2,V4);
handler.connectBlocks(VMix2,E1,V7);
handler.connectBlocks(F0,VMix2,V6);
handler.connectBlocks(F1,VMix4,V9);
handler.connectBlocks(E1,VMix4,V8);
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

% Vout.temperature = 60 + 273.16;
% Vout.fixedTemperature = true;

%% Bounds

engine.QBounds = [7.e3,73.e3];
engine.ABounds = [458,7320];
engine.x_disBounds = [0.2,0.5];
engine.x_totBounds = [0.2,0.5];
engine.temperatureBounds = [40,120]+273.16;
engine.pressureBounds = [satP(engine.temperatureBounds(1),SteamCoefficients())
                         satP(engine.temperatureBounds(2),SteamCoefficients())]*1000;

                    
addInfo = {};
addInfo.Vin = S;
addInfo.Vout = Vout;

addInfo.LSpl1 = LSpl1;
addInfo.VSpl0 = VSpl0;
addInfo.LSpl3 = LSpl3;
addInfo.LSpl2 = LSpl2;
addInfo.VSpl4 = VSpl4;

addInfo.EPAR = EPAR;
addInfo.ESER = ESER;

addInfo.BLToPar = BLToPar;
addInfo.BLToSer = BLToSer;

engine.addInfo = addInfo;

[lb,ub] = engine.getBounds(engine.handler);

lb = [lb;0;0;0;0;0;60+273.16];
ub = [ub;1;1;1;1;1;100+273.16];



fun = @(x) engine.evaluateBalances(x,engine.handler);
