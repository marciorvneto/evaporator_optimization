clear all, close all, clc

addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');

%% Block definitions

% Here we define evaporators E1A - E6. Notice that the definitions take the the form
% Evaporator(U,A), where U is the global heat exchange coefficient in kW/m²K and A
% is the heat exchange area in m²

E1A = Evaporator(1.062,408.77);
E1B = Evaporator(1.397,408.77);
E2 = Evaporator(2.402,817.55);
E3 = Evaporator(2.220,817.55);
E4 = Evaporator(1.777,817.55);
E5 = Evaporator(1.323,817.55);
E6 = Evaporator(1.062,817.55);

% Here we define the vapor and liquid streams.

V_0_VSP1 = VaporStream('V_0_Split','VAPO');
V_VSP1_1A = VaporStream('V_Split_1A','VAPO');
V_VSP1_1B = VaporStream('V_Split_1B','VAPO');
V_1A_VMX1 = VaporStream('V_1A_Mix','VAPO');
V_1B_VMX1 = VaporStream('V_1B_Mix','VAPO');
V_VMX1_2 = VaporStream('V_1A1B_Combined','VAPO');
V_2_3 = VaporStream('V_2_3','VAPO');
V_3_4 = VaporStream('V_3_4','VAPO');
V_4_5 = VaporStream('V_4_5','VAPO');
V_5_6 = VaporStream('V_5_6','VAPO');
V_6_Condenser = VaporStream('V_6_Condenser','VAPO');

L_0_LSP1 = LiquidStream('L_0_Split','BLIQ');
L_LSP1_6 = LiquidStream('L_Split_6','BLIQ');
L_LSP1_5 = LiquidStream('L_Split_5','BLIQ');
L_6_LMX1 = LiquidStream('L_6_Mix','BLIQ');
L_5_LMX1 = LiquidStream('L_5_Mix','BLIQ');
L_LMX1_4 = LiquidStream('L_Mix_4','BLIQ');
L_4_3 = LiquidStream('L_4_3','BLIQ');
L_3_2 = LiquidStream('L_3_2','BLIQ');
L_2_1B = LiquidStream('L_2_1B','BLIQ');
L_1B_1A = LiquidStream('L_1B_1A','BLIQ');
L_1A_FlashBL = LiquidStream('L_1A_FlashBL','BLIQ');

C_1A = LiquidStream('C_1A','COND');
C_1B = LiquidStream('C_1B','COND');
C_2 = LiquidStream('C_2','COND');
C_3 = LiquidStream('C_3','COND');
C_4 = LiquidStream('C_4','COND');
C_5 = LiquidStream('C_5','COND');
C_6 = LiquidStream('C_6','COND');


% Here we define the liquid and vapor mixers and splitters.

VMX1 = VMixer();
LMX1 = LMixer();
VSP1 = VSplitter(0.5);
LSP1 = LSplitter(0.5);


%% Input data

V_0_VSP1.temperature = 408.58;
V_0_VSP1.flow = 6.51;
V_0_VSP1.fixedTemperature = true;
V_0_VSP1.fixedFlow = true;

L_0_LSP1.flow = 0.042;
L_0_LSP1.x_dis = 0.1393;
L_0_LSP1.x_tot = 0.1393;
L_0_LSP1.fixedFlow = true;
L_0_LSP1.fixedX_Dis = true;
L_0_LSP1.fixedX_Tot = true;

% Solids out

L_1A_FlashBL.x_dis = 0.514;
L_1A_FlashBL.fixedX_Dis = true;

%% Simulator setup

% We need to create a Handler to collect all the elements created above.

handler = Handler();

handler.addStream(V_0_VSP1);
handler.addStream(V_VSP1_1A);
handler.addStream(V_VSP1_1B);
handler.addStream(V_1A_VMX1);
handler.addStream(V_1B_VMX1);
handler.addStream(V_VMX1_2);
handler.addStream(V_2_3);
handler.addStream(V_3_4);
handler.addStream(V_4_5);
handler.addStream(V_5_6);
handler.addStream(V_6_Condenser);

handler.addStream(L_0_LSP1);
handler.addStream(L_LSP1_5);
handler.addStream(L_LSP1_6);
handler.addStream(L_6_LMX1);
handler.addStream(L_5_LMX1);
handler.addStream(L_LMX1_4);
handler.addStream(L_4_3);
handler.addStream(L_3_2);
handler.addStream(L_2_1B);
handler.addStream(L_1B_1A);
handler.addStream(L_1A_FlashBL);

handler.addStream(C_1A);
handler.addStream(C_1B);
handler.addStream(C_2);
handler.addStream(C_3);
handler.addStream(C_4);
handler.addStream(C_5);
handler.addStream(C_6);

handler.addBlock(VSP1);
handler.addBlock(VMX1);
handler.addBlock(E1A);
handler.addBlock(E1B);
handler.addBlock(E2);
handler.addBlock(E3);
handler.addBlock(E4);
handler.addBlock(E5);
handler.addBlock(E6);
handler.addBlock(LMX1);
handler.addBlock(LSP1);

%% Connectivity

% Vapor

handler.connectInStream(VSP1,V_0_VSP1);
handler.connectOutStream(VSP1,V_VSP1_1A);
handler.connectOutStream(VSP1,V_VSP1_1B);


handler.connectBlocks(VSP1,E1A,V_VSP1_1A);
handler.connectBlocks(VSP1,E1B,V_VSP1_1B);
handler.connectBlocks(E1A,VMX1,V_1A_VMX1);
handler.connectBlocks(E1B,VMX1,V_1B_VMX1);
handler.connectBlocks(VMX1,E2,V_VMX1_2);
handler.connectBlocks(E2,E3,V_2_3);
handler.connectBlocks(E3,E4,V_3_4);
handler.connectBlocks(E4,E5,V_4_5);
handler.connectBlocks(E5,E6,V_5_6);

handler.connectOutStream(E6,V_6_Condenser);

% Black liquor

handler.connectInStream(LSP1,L_0_LSP1);
handler.connectOutStream(LSP1,L_LSP1_6);
handler.connectOutStream(LSP1,L_LSP1_5);

handler.connectBlocks(LSP1,E6,L_LSP1_6);
handler.connectBlocks(LSP1,E5,L_LSP1_5);
handler.connectBlocks(E6,LMX1,L_6_LMX1);
handler.connectBlocks(E5,LMX1,L_5_LMX1);
handler.connectBlocks(LMX1,E4,L_LMX1_4);
handler.connectBlocks(E4,E3,L_4_3);
handler.connectBlocks(E3,E2,L_3_2);
handler.connectBlocks(E2,E1B,L_2_1B);
handler.connectBlocks(E1B,E1A,L_1B_1A);

handler.connectOutStream(E1A,L_1A_FlashBL);

% Condensates

handler.connectOutStream(E1A,C_1A);
handler.connectOutStream(E1B,C_1B);
handler.connectOutStream(E2,C_2);
handler.connectOutStream(E3,C_3);
handler.connectOutStream(E4,C_4);
handler.connectOutStream(E5,C_5);
handler.connectOutStream(E6,C_6);

%% Engine setup

engine = Engine(handler);

%%  ========= Objective function ===========

fun = @(x) engine.evaluateBalances(x,engine.handler);

objectiveFunction = @(x) fun(x)'*fun(x); % <----- call this
[lb,ub] = engine.getBounds(engine.handler); % <----- upper and lower bounds
