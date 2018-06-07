classdef Optimizer < handle
    %This class handles the optimization subroutines
        
    properties
        engine;
    end
    
    methods
        function obj = Optimizer(engine)
            obj.engine = engine;
        end
        function obj = makeSplittersMixers(obj,engine)
            NewEvap = Evaporator();
            for n=1:length(engine.getStreams())                
                currentStream = engine.getStream(n);
                if strcmp(currentStream.type,'VSTREAM')
                    newLiveSteam = VaporStream('New live steam','VAPO');
                    allVapor = VaporStream('New live steam','VAPO');
                    mixAll = VMixer();
                    handler.connectInStream(mixAll,newLiveSteam);
                    
                    obj.makeSplittersMixersVapor(currentStream,engine.handler,mixAll);
                    
                end
                if strcmp(currentStream.type,'LSTREAM')
                    obj.makeSplittersMixersLiquid(currentStream,engine.handler);                    
                end                
            end
        end
        function y = makeSplittersMixersVapor(obj,currentStream,handler,mixAll)
            newSplitter = Splitter(0.5);
            newMixer  = VMixer();
            
            inStream = VaporStream([currentStream.name,'_inMix'],'VAPO');
            outStream = VaporStream([currentStream.name,'_OutSplit'],'VAPO');
            connectMixSplit = VaporStream([currentStream.name,'_connectMixSplit'],'VAPO');
            
            %Create an extra stream if needed
            
            if currentStream.hasOriginBlock()
                connectOriginMix = VaporStream([currentStream.name,'_connectOriginMix'],'VAPO');
                handler.connectBlocks(currentStream.originBlock,newMixer,connectOriginMix);                
            end
            
            %Disconnect old streams
            
            if currentStream.hasOriginBlock()                
                handler.disconnectOutStream(currentStream.originBlock,currentStream);
            end
            
            %Connect everything else            
                                    
            handler.connectOutStream(newSplitter,currentStream);
            handler.connectBlocks(newSplitter,mixAll,outStream);            
            handler.connectInStream(newMixer,inStream);
            handler.connectBlocks(newMixer,newSplitter,connectMixSplit);            
            
        end
        function y = makeSplittersMixersLiquid(obj,currentStream,handler)
            y=0;
        end
    end
    
end

