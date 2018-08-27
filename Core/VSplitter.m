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
            y(3) = (F1 - F1split)/1;
            y(4) = (F2 - F2split)/1;
            y(5) = (P1 - Pin)/100;
            y(6) = (P2 - Pin)/100;

%             y(1) = (Tin - T1)/1;
%             y(2) = (Tin - T2)/1;
%             y(3) = (F1 - F1split)/1;
%             y(4) = (F2 - F2split)/1;
%             y(5) = (P1 - Pin)/1;
%             y(6) = (P2 - Pin)/1;
            
            
        end
        
        function y = evaluateEasy(obj,var)
            
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
%             y(1) = (Tin - T1);
%             y(2) = (Tin - T2);
%             y(3) = (F1 - F1split);
%             y(4) = (F2 - F2split);
%             y(5) = (P1 - Pin);
%             y(6) = (P2 - Pin);
            
            y(1) = (Tin - T1)/100;
            y(2) = (Tin - T2)/100;
            y(3) = (F1 - F1split)/1;
            y(4) = (F2 - F2split)/1;
            y(5) = (P1 - Pin)/100;
            y(6) = (P2 - Pin)/100;
           
            
        end
        
        function [A,i] = adjacencyEasy(obj,A,i)
            vaporIn = obj.vaporIn();
            outStreams = obj.vaporOutStreams();
            
            indices1 = [vaporIn.iTemperature,outStreams{1}.iTemperature];
            indices2 = [vaporIn.iTemperature,outStreams{2}.iTemperature];
            indices3 = [vaporIn.iFlow,outStreams{1}.iFlow];
            indices4 = [vaporIn.iFlow,outStreams{2}.iFlow];
            indices5 = [vaporIn.iPressure,outStreams{1}.iPressure];
            indices6 = [vaporIn.iPressure,outStreams{2}.iPressure];
            
            A(i,indices1) = 1;
            A(i+1,indices2) = 1;
            A(i+2,indices3) = 1;
            A(i+3,indices4) = 1;
            A(i+4,indices5) = 1;
            A(i+5,indices6) = 1;
            
            i = i + 6;
            
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

