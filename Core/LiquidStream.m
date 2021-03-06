classdef LiquidStream < Stream
    %A stream that only represents black liquor flow
    
    properties
        x_tot;
        x_dis;
        fixedX_Tot;
        fixedX_Dis;
        
        iX_tot;
        iX_dis;
    end
    
    methods
        function obj = LiquidStream(name,subtype)
            obj = obj@Stream('LSTREAM',name,subtype);           
            obj.fixedX_Tot = false;
            obj.fixedX_Dis = false;
            obj.iX_tot = -1;
            obj.iX_dis = -1;
            
            obj.x_dis = 0.5;
            obj.x_tot = 0.5;
        end
        function [lb,ub] = getBounds(obj,engine,lb,ub)
            [lb,ub] = getBounds@Stream(obj,engine,lb,ub);
            lb(obj.iX_dis) = engine.x_disBounds(1);
            ub(obj.iX_dis) = engine.x_disBounds(2);
            lb(obj.iX_tot) = engine.x_totBounds(1);
            ub(obj.iX_tot) = engine.x_totBounds(2);
        end
        function y = numUnknowns(obj)
            y = numUnknowns@Stream(obj) + 2;
        end
        function y = numEquations(obj)
            y = numEquations@Stream(obj) + obj.fixedX_Dis + obj.fixedX_Tot;
        end
        function y = preallocateVariables(obj,startingIndex)
            startingIndex = preallocateVariables@Stream(obj,startingIndex);
            obj.iX_tot = startingIndex;
            obj.iX_dis = startingIndex + 1;
            y = startingIndex + 2;
        end
        function guess = transportInitialGuesses(obj,var)
            guess = var;
            guess(obj.iFlow) = obj.flow;
            guess(obj.iTemperature) = obj.temperature;
            guess(obj.iX_dis) = obj.x_dis;
            guess(obj.iX_tot) = obj.x_tot;
        end
        function obj = fetchVariables(obj,result)
            obj.flow = result(obj.iFlow);
            obj.temperature = result(obj.iTemperature);
            obj.x_dis = result(obj.iX_dis);
            obj.x_tot = result(obj.iX_tot);
        end
        function y = evaluate(obj,var)
            y = evaluate@Stream(obj,var);
            if(obj.fixedX_Dis)
                y(end+1) = var(obj.iX_dis) - obj.x_dis;
            end
            if(obj.fixedX_Tot)
                y(end+1) = var(obj.iX_tot) - obj.x_tot;
            end
        end
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(obj.numKnown(),numVars);
            rowb = zeros(obj.numKnown(),1);
            index=1;
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
            if(obj.fixedX_Dis)
                rowA(index,obj.iX_dis) = 1;
                rowb(index) = obj.x_dis;
                index = index+1;
            end
            if(obj.fixedX_Tot)
                rowA(index,obj.iX_tot) = 1;
                rowb(index) = obj.x_tot;
                index = index+1;
            end        
        end
    end
    
end

