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
                Hin(n) = BlackLiquor.h(X_dis_in(n),Tin(n));
            end
           
            Fout = var(liquidOut.iFlow);
            Tout = var(liquidOut.iTemperature);            
            X_dis_out = var(liquidOut.iX_dis);
            X_tot_out = var(liquidOut.iX_tot);
            Hout = BlackLiquor.h(X_dis_out,Tout);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (Fout - sum(Fin))/10;
            y(2) = (Fout*Hout - Fin'*Hin)/10000;
            y(3) = (Fout*X_dis_out - Fin'*X_dis_in)/10;
            y(4) = (Fout*X_tot_out - Fin'*X_tot_in)/10;
            
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

