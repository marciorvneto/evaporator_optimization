classdef CondensateStream < Stream
    %A stream that only represents black liquor flow
    
    properties
        pressure;       
        
        iPressure;
        
        fixedPressure;
    end
    
    methods
        function obj = CondensateStream(name,subtype)
            obj = obj@Stream('CSTREAM',name,subtype);           
            obj.fixedPressure = false;

            obj.iPressure = -1;
            
            obj.pressure = 1;

        end
        function y = numUnknowns(obj)
            y = numUnknowns@Stream(obj) + 1;
        end
        function y = numEquations(obj)
            y = numEquations@Stream(obj) + obj.fixedPressure;
        end
        function [lb,ub] = getBounds(obj,engine,lb,ub)
            [lb,ub] = getBounds@Stream(obj,engine,lb,ub);
            lb(obj.iPressure) = engine.pressureBounds(1);
            ub(obj.iPressure) = engine.pressureBounds(2);
        end
        function y = preallocateVariables(obj,startingIndex)
            startingIndex = preallocateVariables@Stream(obj,startingIndex);
            obj.iPressure = startingIndex;
            y = startingIndex + 1;
        end
        function guess = transportInitialGuesses(obj,var)
            guess = var;
            guess(obj.iFlow) = obj.flow;
            guess(obj.iTemperature) = obj.temperature;
            guess(obj.iPressure) = obj.pressure;
        end
        function obj = fetchVariables(obj,result)
            obj.flow = result(obj.iFlow);
            obj.temperature = result(obj.iTemperature);
            obj.pressure = result(obj.iPressure);
        end
        function y = evaluate(obj,var)
            y = evaluate@Stream(obj,var);
            if(obj.fixedPressure)
                y(end+1) = (var(obj.iPressure) - obj.pressure)/100;
            end
%             if(obj.fixedPressure)
%                 y(end+1) = (var(obj.iPressure) - obj.pressure)/1;
%             end
        end
%         function [rowA,rowb] = linearConstraints(obj,numVars)
% 
%             rowA = zeros(obj.numKnown(),numVars);
%             rowb = zeros(obj.numKnown(),1);
%             index=1;
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
%             if(obj.fixedX_Dis)
%                 rowA(index,obj.iX_dis) = 1;
%                 rowb(index) = obj.x_dis;
%                 index = index+1;
%             end
%             if(obj.fixedX_Tot)
%                 rowA(index,obj.iX_tot) = 1;
%                 rowb(index) = obj.x_tot;
%                 index = index+1;
%             end        
%         end
    end
    
end

