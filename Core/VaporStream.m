classdef VaporStream < Stream
    %A stream that only represents vapor flow
    
    properties
        fixedPressure;

        iPressure;
            
        pressure;
    end
    
    methods
        function obj = VaporStream(name,subtype)
            obj = obj@Stream('VSTREAM',name,subtype);
            
            obj.fixedPressure = false;

            obj.iPressure = -1;

            obj.pressure = 1;
        end
        function [lb,ub] = getBounds(obj,engine,lb,ub)
            [lb,ub] = getBounds@Stream(obj,engine,lb,ub);
            lb(obj.iPressure) = engine.pressureBounds(1);
            ub(obj.iPressure) = engine.pressureBounds(2);
        end
        function y = numUnknowns(obj)
            y = numUnknowns@Stream(obj) + 1;
        end
        function y = numKnown(obj)
            y = numKnown@Stream(obj) + obj.fixedPressure;
        end
        function y = preallocateVariables(obj,startingIndex)
            startingIndex = preallocateVariables@Stream(obj,startingIndex);
            obj.iPressure = startingIndex;
            y = startingIndex + 1;
        end
        function obj = fetchVariables(obj,result)
            obj.flow = result(obj.iFlow);
            obj.temperature = result(obj.iTemperature);
            obj.pressure = result(obj.iPressure);
        end
        function guess = transportInitialGuesses(obj,var)
            guess = var;
            guess(obj.iFlow) = obj.flow;
            guess(obj.iTemperature) = obj.temperature;
            guess(obj.iPressure) = obj.pressure;
        end
        function y = evaluate(obj,var)
            y = [];
            if(obj.fixedFlow)
                y(end+1) = var(obj.iFlow) - obj.flow;
            end
            if(obj.fixedTemperature)
                y(end+1) = var(obj.iTemperature) - obj.temperature;
            end
            if(obj.fixedPressure)
                y(end+1) = var(obj.iPressure) - obj.pressure;
            end
        end
%         function [rowA,rowb] = linearConstraints(obj,numVars)
% 
%             rowA = zeros(obj.numKnown(),numVars);
%             rowb = zeros(obj.numKnown(),1);
%             index = 1;
%             if(obj.fixedFlow)
%                 rowA(index,obj.iFlow) = 1;
%                 rowb(index) = obj.flow;
%                 index = index+1;
%             end
%             if(obj.fixedTemperature)
%                 rowA(index,obj.iTemperature) = 1;
%                 rowb(index) = obj.temperature;
%                 index = index+1;
%             end       
%         end
    end
    
end

