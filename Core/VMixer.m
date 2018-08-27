classdef VMixer < Block
    %Mixer block
    %   Mixes a collection of streams into a single one
    
    properties
        condensate;
    end
    
    methods
        function obj = VMixer(name)
            obj = obj@Block(name);
            obj.condensate = false;
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
                if obj.condensate
                    Hin(n) = hLSatT(Tin(n),obj.Const);                    
                else
                    Hin(n) = hVSatT(Tin(n),obj.Const);
                end
            end
           
            Fout = var(vaporOut.iFlow);
            Tout = var(vaporOut.iTemperature);
            if obj.condensate
                Hout =  hLSatT(Tout,obj.Const);
            else
                Hout =  hVSatT(Tout,obj.Const);
            end
            
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
            y(1) = (Fout - sum(Fin))/1;
            y(2) = (Fout*Hout - Fin'*Hin)/1000;
            y(3) = (var(inStreams{1}.iPressure) - var(vaporOut.iPressure))/100;
            for n=2:length(inStreams)
                stream1 = inStreams{n};
                stream2 = inStreams{n-1};
                P1 = var(stream1.iPressure);
                P2 = var(stream2.iPressure);
                y(3+n-1) = (P1 - P2)/100; 
            end

%             y(1) = (Fout - sum(Fin))/1;
%             y(2) = (Fout*Hout - Fin'*Hin)/1;
%             y(3) = (var(inStreams{1}.iPressure) - var(vaporOut.iPressure))/1;
%             for n=2:length(inStreams)
%                 stream1 = inStreams{n};
%                 stream2 = inStreams{n-1};
%                 P1 = var(stream1.iPressure);
%                 P2 = var(stream2.iPressure);
%                 y(3+n-1) = (P1 - P2)/1; 
%             end
            
        end
        
        function y = evaluateEasy(obj,var)
            
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
                if obj.condensate
                    Hin(n) = hLSatT(Tin(n),obj.Const);                    
                else
                    Hin(n) = hVSatT(Tin(n),obj.Const);
                end
            end
           
            Fout = var(vaporOut.iFlow);
            Tout = var(vaporOut.iTemperature);
            if obj.condensate
                Hout =  hLSatT(Tout,obj.Const);
            else
                Hout =  hVSatT(Tout,obj.Const);
            end
            
            
            % System of equations
            
            y = zeros(obj.numEquations(),1);
%             y(1) = (Fout - sum(Fin));
%             y(2) = (Fout*Hout - Fin'*Hin);
%             y(3) = (var(inStreams{1}.iPressure) - var(vaporOut.iPressure));
%             for n=2:length(inStreams)
%                 stream1 = inStreams{n};
%                 stream2 = inStreams{n-1};
%                 P1 = var(stream1.iPressure);
%                 P2 = var(stream2.iPressure);
%                 y(3+n-1) = (P1 - P2); 
%             end
            
            y(1) = (Fout - sum(Fin))/1;
            y(2) = (Fout*Hout - Fin'*Hin)/1000;
            y(3) = (var(inStreams{1}.iPressure) - var(vaporOut.iPressure))/100;
            for n=2:length(inStreams)
                stream1 = inStreams{n};
                stream2 = inStreams{n-1};
                P1 = var(stream1.iPressure);
                P2 = var(stream2.iPressure);
                y(3+n-1) = (P1 - P2)/100; 
            end
            
        end
        
        function [A,i] = adjacencyEasy(obj,A,i)
            vaporOut = obj.vaporOut();
            inStreams = obj.vaporInStreams();            
                        
           for n=1:length(inStreams)
                currentStream = inStreams{n};
                Fin(n) = (currentStream.iFlow);
                Tin(n) = (currentStream.iTemperature);
           end           
           
           Fout = (vaporOut.iFlow);
           Tout = (vaporOut.iTemperature);
           
           
            indices1 = [Fin,Fout];
            indices2 = [Fin,Fout,Tin,Tout];
            indices3 = [inStreams{1}.iPressure,vaporOut.iPressure];
            
            A(i,indices1) = 1;
            A(i+1,indices2) = 1;
            A(i+2,indices3) = 1;
            
            i = i + 3;            
            
            for n=2:length(inStreams)
                stream1 = inStreams{n};
                stream2 = inStreams{n-1};
                P1 = (stream1.iPressure);
                P2 = (stream2.iPressure);
                indices = [P1,P2];
                A(i,indices) = 1;
                i = i + 1;
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

