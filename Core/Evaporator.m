classdef Evaporator < Block
    %Splitter block
    %   Splits a stream into two currents with the same composition

    properties
        U;
        A;
        Q;
        
        iQ;
        iA;

        fixedA = false;
        fixedQ = false;
        areaEqualTo = -1;
    end

    methods
        function obj = Evaporator(U,A,name)
            obj = obj@Block(name);
            obj.U = U;
            obj.A = A;
            obj.Q = 0;

            obj.iA = -1;
            obj.iQ = -1;
        end

        % ====== Helper ========
        
        function [lb,ub] = getBounds(obj,engine,lb,ub)            
            lb(obj.iA) = engine.ABounds(1);
            ub(obj.iA) = engine.ABounds(2);
            lb(obj.iQ) = engine.QBounds(1);
            ub(obj.iQ) = engine.QBounds(2);
        end
        
        function y = numUnknowns(obj)
            y = numUnknowns@Block(obj) + 2;
        end
        
        function y = numEquations(obj)
            y = 11 + obj.fixedA + obj.fixedQ + (obj.areaEqualTo ~= -1);
        end

        function y = preallocateVariables(obj,startingIndex)
            obj.iA = startingIndex;
            obj.iQ = startingIndex + 1;
            y = startingIndex + 2;
        end
        function obj = fetchVariables(obj,result)
            obj.A = result(obj.iA);
            obj.Q = result(obj.iQ);
        end
        function guess = transportInitialGuesses(obj,var)
            guess = var;
            guess(obj.iA) = obj.A;
            guess(obj.iQ) = obj.Q;
        end

        function y = hasFlashFeed(obj)
            y = false;
            for n = 1:length(obj.inStreams)
                currentStream = obj.getInStream(n);
                if(strcmp(currentStream.type,'VSTREAM') && strcmp(currentStream.subtype,'FLASH'))
                    y = true;
                end
            end
        end

        function y = vaporFeed(obj)
            for n = 1:length(obj.inStreams)
                currentStream = obj.getInStream(n);
                if(strcmp(currentStream.type,'VSTREAM'))
                    y = currentStream;
                end
            end
        end

        function y = flashFeed(obj)
            for n = 1:length(obj.inStreams)
                currentStream = obj.getInStream(n);
                if(strcmp(currentStream.type,'VSTREAM') && strcmp(currentStream.subtype,'FLASH'))
                    y = currentStream;
                end
            end
        end

        function y = liquidFeed(obj)
            for n = 1:length(obj.inStreams)
                currentStream = obj.getInStream(n);
                if(strcmp(currentStream.type,'LSTREAM'))
                    y = currentStream;
                end
            end
        end

        function y = vaporOut(obj)
            for n = 1:length(obj.outStreams)
                currentStream = obj.getOutStream(n);
                if(strcmp(currentStream.type,'VSTREAM'))
                    y = currentStream;
                end
            end
        end

        function y = liquidOut(obj)
            for n = 1:length(obj.outStreams)
                currentStream = obj.getOutStream(n);
                if(strcmp(currentStream.type,'LSTREAM'))
                    y = currentStream;
                end
            end
        end

        function y = condensateOut(obj)
            for n = 1:length(obj.outStreams)
                currentStream = obj.getOutStream(n);
                if(strcmp(currentStream.type,'CSTREAM'))
                    y = currentStream;
                end
            end
        end

        % ====== Math ========

        function y = evaluate(obj,var)

            % Fetch variables

            liquidFeed = obj.liquidFeed();
            vaporFeed = obj.vaporFeed();
            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            condensateOut = obj.condensateOut();

            F = var(liquidFeed.iFlow);
            V = var(vaporOut.iFlow);
            L = var(liquidOut.iFlow);
            S = var(vaporFeed.iFlow);
            C = var(condensateOut.iFlow);

            QQ = var(obj.iQ);
            AA = var(obj.iA);

            TF = var(liquidFeed.iTemperature);
            TS = var(vaporFeed.iTemperature);
            TV = var(vaporOut.iTemperature);
            TL = var(liquidOut.iTemperature);
            TC = var(condensateOut.iTemperature);
            
            PS = var(vaporFeed.iPressure);
            PC = var(condensateOut.iPressure);
            PV = var(vaporOut.iPressure);

            xL_dis = var(liquidOut.iX_dis);
            xL_tot = var(liquidOut.iX_tot);
            xF_dis = var(liquidFeed.iX_dis);
            xF_tot = var(liquidFeed.iX_tot);

            % Enthalpies
            
            hF = BlackLiquor.h(xF_dis,TF);
            hL = BlackLiquor.h(xL_dis,TL);            
            hC = Steam.hLSatT(TS);            
            HS = Steam.hVSatT(TS);
            HV = Steam.hVSatT(TV);
            
            assert(HS > hC)

            % System of equations
            y = zeros(obj.numEquations(),1);
            y(1) = (S - C);
            y(2) = (F - V - L);
            y(3) = (F*xF_dis - L*xL_dis);
            y(4) = (F*xF_tot - L*xL_tot);
            y(5) = (PS - PC);
            y(6) = (TV - (Steam.satT(PV/1000) + BlackLiquor.BPR(xL_dis,PV/1000)));
%             y(6) = (TV - (Steam.satT(PV/1000)))/100;
            y(7) = (TV - TL);
            y(8) = (QQ - S*(HS - hC));
            y(9) = (QQ - obj.U*AA*(TS-TL));
            y(10) = (QQ + F*hF - (V*HV + L*hL));
            y(11) = (TC - Steam.satT(PC/1000));
%             y(11) = (TC - TS)/1;
            
            
            count = 12;
            if(obj.fixedA)
                y(count) = (obj.A - var(obj.iA))/1;
                count = count + 1;
            end
            if(obj.fixedQ)
                y(count) = (obj.Q - var(obj.iQ));
                count = count + 1;
            end
            if (obj.areaEqualTo ~= -1)
               otherEvap = obj.areaEqualTo;
               y(count) = (var(obj.iA) - var(otherEvap.iA));
               count = count + 1;
            end

        end

        function [rowA,rowb] = linearConstraints(obj,numVars)

            rowA = zeros(2,numVars);
            rowb = zeros(2,1);

            liquidFeed = obj.liquidFeed();
            vaporFeed = obj.vaporFeed();
            liquidOut = obj.liquidOut();
            vaporOut = obj.vaporOut();
            condensateOut = obj.condensateOut();

            rowA(1,liquidFeed.iFlow)=1;
            rowA(1,liquidOut.iFlow)=-1;
            rowA(1,vaporOut.iFlow)=-1;

            if(obj.hasFlashFeed())
                flashFeed = obj.flashFeed();
                rowA(2,flashFeed.iFlow)=1;
                rowA(2,vaporFeed.iFlow)=1;
                rowA(2,condensateOut.iFlow)=-1;
            else
                rowA(2,vaporFeed.iFlow)=1;
                rowA(2,condensateOut.iFlow)=-1;
            end

        end



    end

end
