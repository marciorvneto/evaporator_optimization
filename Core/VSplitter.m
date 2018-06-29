classdef VSplitter < Block
    %Splitter block
    %   Splits a stream into two currents with the same composition
    
    properties
        percentToFirstStream;
    end
    
    methods
        function obj = VSplitter(percentToFirstStream)
            obj = obj@Block('VSP');
            obj.percentToFirstStream = percentToFirstStream;
        end
        function y = numEquations(obj)
            y = 4; 
        end
        
        function y = vaporOutStreams(obj)
            y = obj.outStreams;            
        end
        
        function y = vaporIn(obj)
            y = obj.inStreams{1};
        end
        
        % ====== Math ========
        
        function y = evaluate(obj,var)
            
            % Fetch variables

            vaporIn = obj.vaporIn();
            outStreams = obj.vaporOutStreams();
            
            Pin = var(vaporIn.iPressure);
            P1 = var(outStreams{1}.iPressure);
            P2 = var(outStreams{2}.iPressure);
            
            Fin = var(vaporIn.iFlow);
            F1 = var(outStreams{1}.iFlow);
            F2 = var(outStreams{2}.iFlow);
            
            Tin = var(vaporIn.iTemperature);
            T1 = var(outStreams{1}.iTemperature);
            T2 = var(outStreams{2}.iTemperature);
            
            F1split = Fin*obj.percentToFirstStream;
            F2split = Fin-F1split;
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (Tin - T1)/100;
            y(2) = (Tin - T2)/100;
            y(3) = (F1 - F1split)/10;
            y(4) = (F2 - F2split)/10;
            y(5) = (P1 - Pin)/100;
            y(6) = (P2 - Pin)/100;
            
            
        end
        
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(2,numVars);
            rowb = zeros(2,1);
            
            vaporIn = obj.vaporIn();
            outStreams = obj.vaporOutStreams();
            
            for n=1:length(outStreams)
                currentStream = outStreams{n};
                rowA(n,currentStream.iFlow)=1;
                rowA(n,vaporIn.iFlow)=-obj.percentToFirstStream;
            end
      
        end
        
    end
    
end

