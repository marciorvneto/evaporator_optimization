classdef LSplitter < Block
    %Splitter block
    %   Splits a stream into two currents with the same composition
    
    properties
        percentToFirstStream;
    end
    
    methods
        function obj = LSplitter(percentToFirstStream)
            obj = obj@Block('LSP');
            obj.percentToFirstStream = percentToFirstStream;
        end
        function y = numEquations(obj)
            y = 8; 
        end
        
        function y = liquidOutStreams(obj)
            y = obj.outStreams;            
        end
        
        function y = liquidIn(obj)
            y = obj.inStreams{1};
        end
        
        % ====== Math ========
        
        function y = evaluate(obj,var)
            
            % Fetch variables

            liquidIn = obj.liquidIn();
            outStreams = obj.liquidOutStreams();
            
            Fin = var(liquidIn.iFlow);
            F1 = var(outStreams{1}.iFlow);
            F2 = var(outStreams{2}.iFlow);
            
            Tin = var(liquidIn.iTemperature);
            T1 = var(outStreams{1}.iTemperature);
            T2 = var(outStreams{2}.iTemperature);
            
            X_dis_in = var(liquidIn.iX_dis);
            X_dis_1 = var(outStreams{1}.iX_dis);
            X_dis_2 = var(outStreams{2}.iX_dis);
            
            X_tot_in = var(liquidIn.iX_tot);
            X_tot_1 = var(outStreams{1}.iX_tot);
            X_tot_2 = var(outStreams{2}.iX_tot);
            
            F1split = Fin*obj.percentToFirstStream;
            F2split = Fin-F1split;
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (Tin - T1)/100;
            y(2) = (Tin - T2)/100;
            y(3) = X_dis_in - X_dis_1;
            y(4) = X_dis_in - X_dis_2;
            y(5) = X_tot_in - X_tot_1;
            y(6) = X_tot_in - X_tot_2;
            y(7) = (F1 - F1split)/1;
            y(8) = (F2 - F2split)/1;
            
%             y(1) = (Tin - T1)/1;
%             y(2) = (Tin - T2)/1;
%             y(3) = X_dis_in - X_dis_1;
%             y(4) = X_dis_in - X_dis_2;
%             y(5) = X_tot_in - X_tot_1;
%             y(6) = X_tot_in - X_tot_2;
%             y(7) = (F1 - F1split)/1;
%             y(8) = (F2 - F2split)/1;
            
            
        end
        
        function y = evaluateEasy(obj,var)
            
            % Fetch variables

            liquidIn = obj.liquidIn();
            outStreams = obj.liquidOutStreams();
            
            Fin = var(liquidIn.iFlow);
            F1 = var(outStreams{1}.iFlow);
            F2 = var(outStreams{2}.iFlow);
            
            Tin = var(liquidIn.iTemperature);
            T1 = var(outStreams{1}.iTemperature);
            T2 = var(outStreams{2}.iTemperature);
            
            X_dis_in = var(liquidIn.iX_dis);
            X_dis_1 = var(outStreams{1}.iX_dis);
            X_dis_2 = var(outStreams{2}.iX_dis);
            
            X_tot_in = var(liquidIn.iX_tot);
            X_tot_1 = var(outStreams{1}.iX_tot);
            X_tot_2 = var(outStreams{2}.iX_tot);
            
            F1split = Fin*obj.percentToFirstStream;
            F2split = Fin-F1split;
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
%             y(1) = (Tin - T1);
%             y(2) = (Tin - T2);
%             y(3) = X_dis_in - X_dis_1;
%             y(4) = X_dis_in - X_dis_2;
%             y(5) = X_tot_in - X_tot_1;
%             y(6) = X_tot_in - X_tot_2;
%             y(7) = (F1 - F1split);
%             y(8) = (F2 - F2split);
            
            y(1) = (Tin - T1)/100;
            y(2) = (Tin - T2)/100;
            y(3) = X_dis_in - X_dis_1;
            y(4) = X_dis_in - X_dis_2;
            y(5) = X_tot_in - X_tot_1;
            y(6) = X_tot_in - X_tot_2;
            y(7) = (F1 - F1split)/1;
            y(8) = (F2 - F2split)/1;
            
        end
        
        function [A,i] = adjacencyEasy(obj,A,i)
            
            liquidIn = obj.liquidIn();
            outStreams = obj.liquidOutStreams();
            
            Fin = (liquidIn.iFlow);
            F1 = (outStreams{1}.iFlow);
            F2 = (outStreams{2}.iFlow);
            
            Tin = (liquidIn.iTemperature);
            T1 = (outStreams{1}.iTemperature);
            T2 = (outStreams{2}.iTemperature);
            
            X_dis_in = (liquidIn.iX_dis);
            X_dis_1 = (outStreams{1}.iX_dis);
            X_dis_2 = (outStreams{2}.iX_dis);
            
            X_tot_in = (liquidIn.iX_tot);
            X_tot_1 = (outStreams{1}.iX_tot);
            X_tot_2 = (outStreams{2}.iX_tot);
            
            indices1 = [Tin,T1];
            indices2 = [Tin,T2];
            indices3 = [X_dis_in,X_dis_1];
            indices4 = [X_dis_in,X_dis_2];
            indices5 = [X_tot_in,X_tot_1];
            indices6 = [X_tot_in,X_tot_2];
            indices7 = [F1,Fin];
            indices8 = [F2,F1,Fin];
            
            A(i,indices1) = 1;
            A(i+1,indices2) = 1;
            A(i+2,indices3) = 1;
            A(i+3,indices4) = 1;
            A(i+4,indices5) = 1;
            A(i+5,indices6) = 1;
            A(i+6,indices7) = 1;
            A(i+7,indices8) = 1;
            
            i = i + 8;
        end
        
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(2,numVars);
            rowb = zeros(2,1);
            
            liquidIn = obj.liquidIn();
            outStreams = obj.liquidOutStreams();
            
            for n=1:length(outStreams)
                currentStream = outStreams{n};
                rowA(n,currentStream.iFlow)=1;
                rowA(n,liquidIn.iFlow)=-obj.percentToFirstStream;
            end
      
        end
        
    end
    
end

