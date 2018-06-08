classdef CMixer < Block
    %Mixer block
    %   Mixes a collection of streams into a single one
    
    properties
    end
    
    methods
        function obj = CMixer()
            obj = obj@Block('CMX');
        end
        function y = numEquations(obj)
            y = 2; 
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
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                Fin(n) = var(currentStream.iFlow);
                Tin(n) = var(currentStream.iTemperature);
                Hin(n) = BlackLiquor.h(X_dis_in(n),Tin(n));
            end
           
            Fout = var(liquidOut.iFlow);
            Tout = var(liquidOut.iTemperature);            
            Hout = BlackLiquor.h(X_dis_out,Tout);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = Fout - sum(Fin) ;
            y(2) = Fout*Hout - Fin'*Hin;
            
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

