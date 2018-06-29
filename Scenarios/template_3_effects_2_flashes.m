%%%% Defining blocks
E1 = Evaporator(1.6,973.522242261,'EFFECT-2');
E0 = Evaporator(1.2,973.522242261,'EFFECT-1');
E2 = Evaporator(2.0,973.522242261,'EFFECT-3');
F1 = Flash('FLASH-1');
F2 = Flash('FLASH-2');
VMix3 = VMixer('MIX-3');
VMix2 = VMixer('MIX-2');
%%%% Defining streams
L9 = LiquidStream('BLSTREAM-10','BLIQ');
L8 = LiquidStream('BLSTREAM-11','BLIQ');
L11 = LiquidStream('BLSTREAM-12','BLIQ');
L10 = LiquidStream('BLSTREAM-13','BLIQ');
C3 = CondensateStream('CSTREAM-15','COND');
C5 = CondensateStream('CSTREAM-16','COND');
C4 = CondensateStream('CSTREAM-17','COND');
C7 = CondensateStream('CSTREAM-18','COND');
C6 = CondensateStream('CSTREAM-19','COND');
V11 = VaporStream('VSTREAM-17','VAPO');
V10 = VaporStream('VSTREAM-18','VAPO');
V12 = VaporStream('VSTREAM-19','VAPO');
V5 = VaporStream('VSTREAM-20','VAPO');
V7 = VaporStream('VSTREAM-21','VAPO');
V6 = VaporStream('VSTREAM-22','VAPO');
V9 = VaporStream('VSTREAM-23','VAPO');
V8 = VaporStream('VSTREAM-24','VAPO');
%%%% Creating a handler for blocks and streams
handler = Handler();
%%%% Including blocks
handler.addBlock(E1);
handler.addBlock(VMix3);
handler.addBlock(F1);
handler.addBlock(VMix2);
handler.addBlock(F2);
handler.addBlock(E2);
handler.addBlock(E0);
%%%% Including streams
handler.addStream(C5);
handler.addStream(V9);
handler.addStream(L11);
handler.addStream(V5);
handler.addStream(C4);
handler.addStream(V8);
handler.addStream(L10);
handler.addStream(V7);
handler.addStream(V11);
handler.addStream(C7);
handler.addStream(L9);
handler.addStream(V10);
handler.addStream(C3);
handler.addStream(V6);
handler.addStream(C6);
handler.addStream(L8);
handler.addStream(V12);
%%%% Connecting streams
handler.connectBlocks(E2,E1,L9);
handler.connectInStream(E2,L8);
handler.connectOutStream(E0,L11);
handler.connectBlocks(E1,E0,L10);
handler.connectBlocks(E1,F2,C3);
handler.connectOutStream(F1,C5);
handler.connectBlocks(E0,F1,C4);
handler.connectOutStream(E2,C7);
handler.connectOutStream(F2,C6);
handler.connectBlocks(F1,VMix2,V11);
handler.connectOutStream(E2,V10);
handler.connectBlocks(F2,VMix3,V12);
handler.connectInStream(E0,V5);
handler.connectBlocks(VMix2,E1,V7);
handler.connectBlocks(E0,VMix2,V6);
handler.connectBlocks(VMix3,E2,V9);
handler.connectBlocks(E1,VMix3,V8);
%%%% Creating the simulation engine
engine = Engine(handler);
engine.preallocateVariables(engine.handler);
