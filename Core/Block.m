classdef Block < handle
    %Abstract class representing a block
    %   Implements basic connectivity methods

    properties
        type;
        inStreams;
        outStreams;
        index;
        
        Const;
    end

    methods
        function obj = Block(type)
           obj.type = type;
           obj.inStreams = {};
           obj.outStreams = {};
           obj.index = -1;
           
           obj.Const = SteamCoefficients();
        end
        
        function [lb,ub] = getBounds(obj,engine,lb,ub)            
        end
        
        function y = numUnknowns(obj)
            y = 0;
        end
        function y = numKnown(obj)
            y = 0;
        end
      
        function y = preallocateVariables(~,startingIndex)
            y = startingIndex;
        end
        
        function obj = fetchVariables(obj,~)
        end
        
        function guess = transportInitialGuesses(~,~)
        end
        
        function y = evaluateEasy(obj,var)
            y = obj.evaluate(var);
        end
        
        function obj = addInStream(obj,stream)
           obj.inStreams{end+1} = stream;
        end

        function obj = addOutStream(obj,stream)
           obj.outStreams{end+1} = stream;
        end

        function y = getInStream(obj,n)
            y = obj.inStreams{n};
        end

        function y = getOutStream(obj,n)
            y = obj.outStreams{n};
        end
    end

end
