classdef VMixer < Block
    %Mixer block
    %   Mixes a collection of streams into a single one
    
    properties
    end
    
    methods
        function obj = VMixer()
            obj = obj@Block('VMX');
        end
        function y = numEquations(obj)
            y = 2; 
        end
        
        function y = vaporOut(obj)
            y = obj.getOutStream(1);            
        end
        
        function y = vaporInStreams(obj)
            y = obj.inStreams;            
        end
        
        % ====== Math ========
        
        function y = evaluate(obj,var)
            
            % Fetch variables

            vaporOut = obj.vaporOut();
            inStreams = obj.vaporInStreams();
            
            Fin = zeros(length(inStreams),1);
            Tin = zeros(length(inStreams),1);
            Hin = zeros(length(inStreams),1);
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                Fin(n) = var(currentStream.iFlow);
                Tin(n) = var(currentStream.iTemperature);
                Hin(n) = hSatV_T(Tin(n));
            end
           
            Fout = var(vaporOut.iFlow);
            Tout = var(vaporOut.iTemperature);
            Hout =  hSatV_T(Tout);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = Fout - sum(Fin) ;
            y(2) = Fout*Hout - Fin'*Hin;
            
            y(2) = 0.001*y(2);
            
        end
        
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(1,numVars);
            
            vaporOut = obj.vaporOut();
            inStreams = obj.vaporInStreams();
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                rowA(currentStream.iFlow)=1;                
            end
            rowA(vaporOut.iFlow)=-1;
            rowb = 0;            
            
            
        end
        
    end
    
end

