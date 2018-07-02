classdef Flash < Block
    %Flash block
    %   Flashes the condensate
    
    properties
    end
    
    methods
        function obj = Flash(name)
            obj = obj@Block(name);
        end
        
        % ====== Helper ========
        
        function y = numEquations(obj)
            y = 4; 
        end
        
        function y = vaporOut(obj)
            for n = 1:length(obj.outStreams)
                currentStream = obj.getOutStream(n);
                if(strcmp(currentStream.type,'VSTREAM'))
                    y = currentStream;
                end
            end
        end
        
        function y = liquidOut(obj)
            for n = 1:length(obj.outStreams)
                currentStream = obj.getOutStream(n);
                if(strcmp(currentStream.type,'CSTREAM'))
                    y = currentStream;
                end
            end
        end
        
        function y = condensateIn(obj)
            for n = 1:length(obj.inStreams)
                currentStream = obj.getInStream(n);
                if(strcmp(currentStream.type,'CSTREAM'))
                    y = currentStream;
                end
            end
        end
        
        % ====== Math ========
        
        function y = evaluate(obj,var)
            
            % Fetch variables

            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            condensateIn = obj.condensateIn();
            
            F = var(condensateIn.iFlow);
            V = var(vaporOut.iFlow);
            L = var(liquidOut.iFlow);
            
            TF = var(condensateIn.iTemperature);
            TV = var(vaporOut.iTemperature);
            TL = var(liquidOut.iTemperature);
            
            PV = var(vaporOut.iPressure);
            PL = var(liquidOut.iPressure);
           
            
            % Enthalpies
            
            hL = hLSatT(TV,obj.Const);
            hF = hLSatT(TF,obj.Const);
            HV = hVSatT(TV,obj.Const);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (F - L - V)/10;
            y(2) = (TV - TL)/100;
            y(3) = (F*hF - (L*hL + V*HV))/10000;
            y(4) = (PV/1000 - satP(TV,obj.Const))/100;
            y(5) = (PL/1000 - satP(TV,obj.Const))/100;            
          

        end
        
        function y = evaluateEasy(obj,var)
            
            % Fetch variables

            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            condensateIn = obj.condensateIn();
            
            F = var(condensateIn.iFlow);
            V = var(vaporOut.iFlow);
            L = var(liquidOut.iFlow);
            
            TF = var(condensateIn.iTemperature);
            TV = var(vaporOut.iTemperature);
            TL = var(liquidOut.iTemperature);
            
            PV = var(vaporOut.iPressure);
            PL = var(liquidOut.iPressure);
           
            
            % Enthalpies
            
            hL = hLSatT(TV,obj.Const);
            hF = hLSatT(TF,obj.Const);
            HV = hVSatT(TV,obj.Const);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (F - L - V)/10;
            y(2) = (TV - TL)/10;
            y(3) = (F*100 - (L*100 + V*2300))/10000;
            y(4) = (PV/1000 - satP(TV,obj.Const))/100;
            y(5) = (PL/1000 - satP(TV,obj.Const))/100;            
          

        end
        
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(1,numVars);
            
            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            condensateIn = obj.condensateIn();
            
            rowA(condensateIn.iFlow)=-1;
            rowA(vaporOut.iFlow)=1;
            rowA(liquidOut.iFlow)=1;
            rowb = 0;            
        end
        
    end
    
end

