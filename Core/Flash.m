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
            y(1) = (F - L - V)/1;
            y(2) = (TV - TL)/100;
            y(3) = (F*hF - (L*hL + V*HV))/1000;
            y(4) = (PV/1000 - satP(TV,obj.Const))/100;
            y(5) = (PL/1000 - satP(TV,obj.Const))/100; 

%             y(1) = (F - L - V)/1;
%             y(2) = (TV - TL)/1;
%             y(3) = (F*hF - (L*hL + V*HV))/1;
%             y(4) = (PV/1000 - satP(TV,obj.Const))/1;
%             y(5) = (PL/1000 - satP(TV,obj.Const))/1;    
          

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
            
            hL = hLSatT(TV,obj.Const);
            hF = hLSatT(TF,obj.Const);
            HV = hVSatT(TV,obj.Const);
           
           
            % System of equations
            
            y = zeros(obj.numEquations(),1);
%             y(1) = (F - L - V);
%             y(2) = (TV - TL);
%             y(3) = (F*100 - (L*100 + V*2300));
%             y(4) = (PV/1000 - satP(TV,obj.Const));
%             y(5) = (PL/1000 - satP(TV,obj.Const));         
            
            y(1) = (F - L - V)/1;
            y(2) = (TV - TL)/100;
            y(3) = (F*hF - (L*hL + V*HV))/1000;
            y(4) = (PV/1000 - satP(TV,obj.Const))/100;
            y(5) = (PL/1000 - satP(TV,obj.Const))/100;   
          

        end
        
        function [A,i] = adjacencyEasy(obj,A,i)
            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            condensateIn = obj.condensateIn();
            
            indices1 = [condensateIn.iFlow,liquidOut.iFlow,vaporOut.iFlow];
            indices2 = [liquidOut.iTemperature,vaporOut.iTemperature];
            indices3 = [condensateIn.iFlow,liquidOut.iFlow,vaporOut.iFlow,vaporOut.iTemperature,condensateIn.iTemperature];
            indices4 = [vaporOut.iPressure,vaporOut.iTemperature];
            indices5 = [liquidOut.iPressure,vaporOut.iTemperature];
            
            A(i,indices1) = 1;
            A(i+1,indices2) = 1;
            A(i+2,indices3) = 1;
            A(i+3,indices4) = 1;
            A(i+4,indices5) = 1;
            
            i = i + 5;
            
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

