classdef Stream < handle
    %Abstract stream class

    properties
        type;
        subtype;
        temperature;
        flow;
        index;
        name;
        
        originBlock;
        endBlock;
        
        fixedTemperature;
        fixedFlow;       
        
        iTemperature;
        iFlow;
        
        Const;
        
        flowBounds = -1;
        temperatureBounds = -1;
    end
    
    methods
        function obj = Stream(type,name,subtype)
            if nargin < 3
                obj.subtype = 'NONE';
            else
                obj.subtype = subtype;
            end
            obj.type = type;            
            obj.fixedTemperature = false;
            obj.fixedFlow = false;
            obj.index = -1;
            obj.name=name;
            obj.iTemperature = -1;
            obj.iFlow = -1;
            
            obj.flow = 1;
            obj.temperature = 320;
            
            obj.originBlock = 0;
            obj.endBlock = 0;
            
            obj.Const = SteamCoefficients();
        end
        function [lb,ub] = getBounds(obj,engine,lb,ub)
            if obj.flowBounds == -1
                lb(obj.iFlow) = engine.flowBounds(1);
                ub(obj.iFlow) = engine.flowBounds(2);                
            else
                lb(obj.iFlow) = obj.flowBounds(1);
                ub(obj.iFlow) = obj.flowBounds(2);
            end
            
            if obj.temperatureBounds == -1
                lb(obj.iTemperature) = engine.temperatureBounds(1);
                ub(obj.iTemperature) = engine.temperatureBounds(2);
            else
                lb(obj.iTemperature) = obj.temperatureBounds(1);
                ub(obj.iTemperature) = obj.temperatureBounds(2);
            end
        end
        function y = preallocateVariables(obj,startingIndex)
            obj.iTemperature = startingIndex;
            obj.iFlow = startingIndex + 1;
            y = startingIndex + 2;
        end
        function y = evaluate(obj,var)
            y = [];
            if(obj.fixedFlow)
                y(end+1) = (var(obj.iFlow) - obj.flow)/10;
            end
            if(obj.fixedTemperature)
                y(end+1) = (var(obj.iTemperature) - obj.temperature)/100;
            end
        end
        function y = numUnknowns(obj)
            y = 2;
        end
        function y = numEquations(obj)
            y = obj.fixedTemperature + obj.fixedFlow ;
        end
        
        function y = hasOriginBlock(obj)
            y = (obj.originBlock ~= 0 );
        end
        
        function y = hasEndBlock(obj)
            y = (obj.endBlock ~= 0 );
        end
        
    end
    
end

