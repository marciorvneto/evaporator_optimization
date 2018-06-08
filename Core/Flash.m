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
            y = 5; 
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
        
        function y = condensateIn(obj)
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
            condensateIn = obj.condensateIn();
            
            F = var(condensateIn.iFlow);
            V = var(vaporOut.iFlow);
            L = var(liquidOut.iFlow);
            
            TF = var(condensateIn.iTemperature);
            TV = var(vaporOut.iTemperature);
            TL = var(liquidOut.iTemperature);

            xL_dis = var(liquidOut.iX_dis);
            xL_tot = var(liquidOut.iX_tot);
            xF_dis = var(condensateIn.iX_dis);
            xF_tot = var(condensateIn.iX_tot);
            
            
            % Enthalpies
            
            lambdaTV = hSatV_T(TV) - hSatL_T(TV);
%             HV = hSatV_T(TV) - hSatL_T(TV);
%             hL = cp(xL_dis,TL)*TL;
%             hF = cp(xF_dis,TF)*TF;
            hL = hSatL_T(TL);
            hF = hSatL_T(TF);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = F - L - V ;
            y(2) = F*xF_dis - L*xL_dis;
            y(3) = F*xF_tot - L*xL_tot;
            y(4) = TV - TL;
%             y(5) = V*lambdaTV - (F*hF + L*hL);
            y(5) = V*lambdaTV + L*cp(xF_dis,TF)*(TL-TF);
%             y(5) = TV - TF;
            
            y(5) = 0.001 * y(5);            

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

