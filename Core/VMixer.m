classdef VMixer < Block
    %Mixer block
    %   Mixes a collection of streams into a single one
    
    properties
    end
    
    methods
        function obj = VMixer(name)
            obj = obj@Block(name);
        end
        function y = numEquations(obj)
            y = 3 + (length(obj.inStreams) - 1); 
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
                Hin(n) = Steam.hVSatT(Tin(n));
            end
           
            Fout = var(vaporOut.iFlow);
            Tout = var(vaporOut.iTemperature);
            Hout =  Steam.hVSatT(Tout);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (Fout - sum(Fin));
            y(2) = (Fout*Hout - Fin'*Hin);
            y(3) = (var(inStreams{1}.iPressure) - var(vaporOut.iPressure));
            for n=2:length(inStreams)
                stream1 = inStreams{n};
                stream2 = inStreams{n-1};
                P1 = var(stream1.iPressure);
                P2 = var(stream2.iPressure);
                y(3+n-1) = (P1 - P2)/100; 
            end

            
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

