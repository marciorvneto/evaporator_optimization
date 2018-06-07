classdef Handler < handle
    %Handler
    %   Handles the connectivity between blocks and steams
    
    properties
        blocks;
        streams;
        blockIndices;
        streamIndices; 
    end
    
    methods
        function obj = Handler()
           obj.blocks = {}; 
           obj.streams = {};
           blockIndices = [];
           streamIndices = [];           
        end
        
        function y = getBlock(obj,n)
            y = obj.blocks{n};
        end
        function y = getStream(obj,n)
            y = obj.streams{n};
        end
        function y = numUnknowns(obj,n)
            y = obj.streams{n}.numUnknowns();
        end
        function y = numEquations(obj,n)
            y = obj.blocks{n}.numEquations();
        end
        % ========== Connectivity ============
        
        function obj = connectBlocks(obj,b1,b2,s)
            b1.addOutStream(s);
            b2.addInStream(s);
            s.originBlock = b1;
            s.endBlock = b2;
        end
        function obj = connectInStream(obj,b,s)            
            b.addInStream(s);            
            s.endBlock = b;            
        end
        function obj = disconnectInStream(obj,b,s)
            for n=1:length(b.inStreams)
                if b.inStreams{n} == s
                    b.inStreams(n)=[];
                    s.endBlock = [];
                    break;
                end
            end
        end
        function obj = disconnectOutStream(obj,b,s)
            for n=1:length(b.outStreams)
                if b.outStreams{n} == s
                    b.outStreams(n)=[];
                    s.originBlock = [];
                    break;
                end
            end
        end
        function obj = connectOutStream(obj,b,s)            
            b.addOutStream(s);            
            s.originBlock = b;            
        end
        function obj = addBlock(obj,b)
           obj.blocks{end+1} = b;
           obj.blockIndices(end+1) = obj.numBlocks();
           b.index = obj.numBlocks();
        end
        function obj = addStream(obj,s)
           obj.streams{end+1} = s;
           obj.streamIndices(end+1) = obj.numStreams();
           s.index = obj.numStreams();
        end
        function y = numBlocks(obj)
            y = length(obj.blocks);
        end
        function y = numStreams(obj)
            y = length(obj.streams);
        end
        
        % ========== Matrix related ============
        
        function A = buildIncidenceMatrix(obj)
           A = zeros(obj.numBlocks(),obj.numStreams()) ;
           for n = 1:obj.numBlocks()
               currentBlock = obj.blocks{n};
               inStreams = currentBlock.inStreams;
               outStreams = currentBlock.outStreams;
               for k = 1:length(inStreams)
                   currentStream = inStreams{k};
                   index = currentStream.index;
                   A(n,index) = -1;
               end
               for k = 1:length(outStreams)
                   currentStream = outStreams{k};
                   index = currentStream.index;
                   A(n,index) = 1;
               end
           end
        end
        
        function indices = vaporStreamIndices(obj)
           indices = [];
           for n = 1:obj.numStreams()
               currentStream = obj.streams{n};
              if strcmp(currentStream.type,'VSTREAM')
                  indices(end+1) = currentStream.index;
              end
           end
        end
        function indices = liquidStreamIndices(obj)
           indices = [];
           for n = 1:obj.numStreams()
               currentStream = obj.streams{n};
              if strcmp(currentStream.type,'LSTREAM')
                  indices(end+1) = currentStream.index;
              end
           end
        end
    end
    
end

