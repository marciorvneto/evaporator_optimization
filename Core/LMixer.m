classdef LMixer < Block
    %Mixer block
    %   Mixes a collection of streams into a single one
    
    properties
    end
    
    methods
        function obj = LMixer()
            obj = obj@Block('LMX');
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
%                 Hin(n) = cp(X_dis_in(n),Tin(n))*Tin(n);
                Hin(n) = hLiq(currentStream,X_dis_in(n),Tin(n));
            end
           
            Fout = var(liquidOut.iFlow);
            Tout = var(liquidOut.iTemperature);            
            X_dis_out = var(liquidOut.iX_dis);
            X_tot_out = var(liquidOut.iX_tot);
%             Hout =  cp(X_dis_out,Tout)*Tout;
            Hout = hLiq(liquidOut,X_dis_out,Tout);
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = Fout - sum(Fin) ;
            y(2) = Fout*Hout - Fin'*Hin;
            y(3) = Fout*X_dis_out - Fin'*X_dis_in;
            y(4) = Fout*X_tot_out - Fin'*X_tot_in;
            
            y(2) = 0.001*y(2);
            
        end
        
        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(1,numVars);
            
            liquidOut = obj.liquidOut();
            inStreams = obj.liquidInStreams();
            
            for n=1:length(inStreams)
                currentStream = inStreams{n};
                rowA(currentStream.iFlow)=1;                
            end
            rowA(liquidOut.iFlow)=-1;
            rowb = 0;            
        end
        
    end
    
end

