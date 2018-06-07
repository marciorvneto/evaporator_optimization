classdef VaporStream < Stream
    %A stream that only represents vapor flow
    
    properties
    end
    
    methods
        function obj = VaporStream(name,subtype)
            obj = obj@Stream('VSTREAM',name,subtype);
        end
        function y = numUnknowns(obj)
            y = numUnknowns@Stream(obj);
        end
        function y = numKnown(obj)
            y = numKnown@Stream(obj);
        end
        function y = preallocateVariables(obj,startingIndex)
            obj.iTemperature = startingIndex;
            obj.iFlow = startingIndex + 1;
            y = startingIndex + 2;
        end
        function obj = fetchVariables(obj,result)
            obj.flow = result(obj.iFlow);
            obj.temperature = result(obj.iTemperature);
        end
        function guess = transportInitialGuesses(obj,var)
            guess = var;
            guess(obj.iFlow) = obj.flow;
            guess(obj.iTemperature) = obj.temperature;
        end
        function y = evaluate(obj,var)
            y = [];
            if(obj.fixedFlow)
                y(end+1) = var(obj.iFlow) - obj.flow;
            end
            if(obj.fixedTemperature)
                y(end+1) = var(obj.iTemperature) - obj.temperature;
            end
        end
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(obj.numKnown(),numVars);
            rowb = zeros(obj.numKnown(),1);
            index = 1;
            if(obj.fixedFlow)
                rowA(index,obj.iFlow) = 1;
                rowb(index) = obj.flow;
                index = index+1;
            end
            if(obj.fixedTemperature)
                rowA(index,obj.iTemperature) = 1;
                rowb(index) = obj.temperature;
                index = index+1;
            end       
        end
    end
    
end

