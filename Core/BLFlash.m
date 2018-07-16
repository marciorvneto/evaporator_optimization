classdef BLFlash < Block
    %Flash block
    %   Flashes the condensate
    
    properties
    end
    
    methods
        function obj = BLFlash(name)
            obj = obj@Block(name);
        end
        
        % ====== Helper ========
        
        function y = numEquations(obj)
            y = 6; 
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
                if(strcmp(currentStream.type,'LSTREAM'))
                    y = currentStream;
                end
            end
        end
        
        function y = liquidIn(obj)
            for n = 1:length(obj.inStreams)
                currentStream = obj.getInStream(n);
                if(strcmp(currentStream.type,'LSTREAM'))
                    y = currentStream;
                end
            end
        end
        
        % ====== Math ========
        
        function y = evaluate(obj,var)
            
            % Fetch variables

            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            liquidIn = obj.liquidIn();
            
            F = var(liquidIn.iFlow);
            V = var(vaporOut.iFlow);
            L = var(liquidOut.iFlow);
            
            xDF = var(liquidIn.iX_dis);
            xTF = var(liquidIn.iX_tot);
            xDL = var(liquidOut.iX_dis);
            xTL = var(liquidOut.iX_tot);
            
            TF = var(liquidIn.iTemperature);
            TV = var(vaporOut.iTemperature);
            TL = var(liquidOut.iTemperature);
            
            PV = var(vaporOut.iPressure);
          
            
            % Enthalpies
            
            hL = h_BL(xDL,TV,obj.Const);
            hF = h_BL(xDF,TF,obj.Const);
            HV = hVSatT(TV,obj.Const);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (F - L - V)/10;
            y(2) = (F*xDF - L*xDL)/10;
            y(3) = (F*xTF - L*xTL)/10;
            y(4) = (TV - TL)/100;
            y(5) = (F*hF - (L*hL + V*HV))/10000;
            y(6) = (PV/1000 - satP(TV,obj.Const))/100;
       
          

        end
        
        function y = evaluateEasy(obj,var)
            
            % Fetch variables

            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            liquidIn = obj.liquidIn();
            
            F = var(liquidIn.iFlow);
            V = var(vaporOut.iFlow);
            L = var(liquidOut.iFlow);
            
            TF = var(liquidIn.iTemperature);
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
            liquidIn = obj.liquidIn();
            
            rowA(liquidIn.iFlow)=-1;
            rowA(vaporOut.iFlow)=1;
            rowA(liquidOut.iFlow)=1;
            rowb = 0;            
        end
        
    end
    
end

