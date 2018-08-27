classdef LMixer < Block
    %Mixer block
    %   Mixes a collection of streams into a single one
    
    properties
    end
    
    methods
        function obj = LMixer(name)
            obj = obj@Block(name);
        end
        function y = numEquations(obj)
            y = 4; 
        end
        
        function y = liquidOut(obj)
            y = obj.getOutStream(1);            
        end
        
        function y = liquidInStreams(obj)
            y = obj.inStreams;            
        end
        
        % ====== Math ========
        
        function y = evaluate(obj,var)
            
            % Fetch variables

            liquidOut = obj.liquidOut();
            inStreams = obj.liquidInStreams();
            
            Fin = zeros(length(inStreams),1);
            Tin = zeros(length(inStreams),1);
            Hin = zeros(length(inStreams),1);
            X_dis_in = zeros(length(inStreams),1);
            X_tot_in = zeros(length(inStreams),1);
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                Fin(n) = var(currentStream.iFlow);
                Tin(n) = var(currentStream.iTemperature);
                X_dis_in(n) = var(currentStream.iX_dis);
                X_tot_in(n) = var(currentStream.iX_tot);
                Hin(n) = h_BL(X_dis_in(n),Tin(n),obj.Const);
            end
           
            Fout = var(liquidOut.iFlow);
            Tout = var(liquidOut.iTemperature);            
            X_dis_out = var(liquidOut.iX_dis);
            X_tot_out = var(liquidOut.iX_tot);
            Hout = h_BL(X_dis_out,Tout,obj.Const);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (Fout - sum(Fin))/1;
            y(2) = (Fout*Hout - Fin'*Hin)/1000;
            y(3) = (Fout*X_dis_out - Fin'*X_dis_in)/1;
            y(4) = (Fout*X_tot_out - Fin'*X_tot_in)/1;
% 
%             y(1) = (Fout - sum(Fin))/1;
%             y(2) = (Fout*Hout - Fin'*Hin)/1;
%             y(3) = (Fout*X_dis_out - Fin'*X_dis_in)/1;
%             y(4) = (Fout*X_tot_out - Fin'*X_tot_in)/1;
            
        end
        
        function y = evaluateEasy(obj,var)
            
            % Fetch variables

            liquidOut = obj.liquidOut();
            inStreams = obj.liquidInStreams();
            
            Fin = zeros(length(inStreams),1);
            Tin = zeros(length(inStreams),1);
            Hin = zeros(length(inStreams),1);
            X_dis_in = zeros(length(inStreams),1);
            X_tot_in = zeros(length(inStreams),1);
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                Fin(n) = var(currentStream.iFlow);
                Tin(n) = var(currentStream.iTemperature);
                X_dis_in(n) = var(currentStream.iX_dis);
                X_tot_in(n) = var(currentStream.iX_tot);
                Hin(n) = h_BL(X_dis_in(n),Tin(n),obj.Const);
            end
           
            Fout = var(liquidOut.iFlow);
            Tout = var(liquidOut.iTemperature);            
            X_dis_out = var(liquidOut.iX_dis);
            X_tot_out = var(liquidOut.iX_tot);
            Hout = h_BL(X_dis_out,Tout,obj.Const);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
%             y(1) = (Fout - sum(Fin));
%             y(2) = (Fout*Hout - Fin'*Hin);
%             y(3) = (Fout*X_dis_out - Fin'*X_dis_in);
%             y(4) = (Fout*X_tot_out - Fin'*X_tot_in);
            
            y(1) = (Fout - sum(Fin))/1;
            y(2) = (Fout*Hout - Fin'*Hin)/1000;
            y(3) = (Fout*X_dis_out - Fin'*X_dis_in)/1;
            y(4) = (Fout*X_tot_out - Fin'*X_tot_in)/1;
            
        end
        
        function [A,i] = adjacencyEasy(obj,A,i)
            liquidOut = obj.liquidOut();
            inStreams = obj.liquidInStreams();
            
            Fin = zeros(length(inStreams),1);
            X_dis_in = zeros(length(inStreams),1);
            X_tot_in = zeros(length(inStreams),1);
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                Fin(n) = (currentStream.iFlow);
                Tin(n) = (currentStream.iTemperature);
                X_dis_in(n) = (currentStream.iX_dis);
                X_tot_in(n) = (currentStream.iX_tot);
            end
           
            Fout = (liquidOut.iFlow);      
            Tout = (liquidOut.iTemperature);      
            X_dis_out = (liquidOut.iX_dis);
            X_tot_out = (liquidOut.iX_tot);
            
            indices1 = [Fin',Fout];
            indices2 = [Fin',Fout,Tin',Tout,X_dis_in',X_dis_out];
            indices3 = [Fin',Fout,X_dis_in',X_dis_out];
            indices4 = [Fin',Fout,X_tot_in',X_tot_out];
            
            A(i,indices1) = 1;
            A(i+1,indices2) = 1;
            A(i+2,indices3) = 1;
            A(i+3,indices4) = 1;
            
            i = i + 4;
            
        end
        
%         function [rowA,rowb] = linearConstraints(obj,numVars)
% 
%             rowA = zeros(1,numVars);
%             
%             liquidOut = obj.liquidOut();
%             inStreams = obj.liquidInStreams();
%             
%             for n=1:length(inStreams)
%                 currentStream = inStreams{n};
%                 rowA(currentStream.iFlow)=1;                
%             end
%             rowA(liquidOut.iFlow)=-1;
%             rowb = 0;            
%         end
        
    end
    
end

