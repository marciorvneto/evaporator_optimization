classdef Evaporator < Block
    %Splitter block
    %   Splits a stream into two currents with the same composition

    properties
        U;
        A;
        Q;

        fixedA = false;
        fixedQ = false;
    end

    methods
        function obj = Evaporator(U,A)
            obj = obj@Block('EVA');
            obj.U = U;
            obj.A = A;
            Q = 0;

            obj.iA = -1;
            obj.iQ = -1;
        end

        % ====== Helper ========
        function y = numUnknowns(obj)
            y = numUnknowns@Block(obj) + 2;
        end
        function y = numKnown(obj)
            y = obj.fixedA + obj.fixedQ;
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
        function y = numEquations(obj)
            y = 10 + 0*obj.hasFlashFeed();
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
                if(strcmp(currentStream.type,'LSTREAM') && ~strcmp(currentStream.subtype,'COND'))
                    y = currentStream;
                end
            end
        end

        function y = condensateOut(obj)
            for n = 1:length(obj.outStreams)
                currentStream = obj.getOutStream(n);
                if(strcmp(currentStream.type,'LSTREAM') && strcmp(currentStream.subtype,'COND'))
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

            Q = var(obj.iQ);
            A = var(obj.iA);

            TF = var(liquidFeed.iTemperature);
            TS = var(vaporFeed.iTemperature);
            TV = var(vaporOut.iTemperature);
            TL = var(liquidOut.iTemperature);
            TC = var(condensateOut.iTemperature);

            xL_dis = var(liquidOut.iX_dis);
            xL_tot = var(liquidOut.iX_tot);
            xF_dis = var(liquidFeed.iX_dis);
            xF_tot = var(liquidFeed.iX_tot);
            xC_dis = var(condensateOut.iX_dis);
            xC_tot = var(condensateOut.iX_tot);

            % Support variables

            Tsat = TL - BPR(xL_dis,TL,1e5);

            % Enthalpies

            lambdaTS = hSatV_T(TS) - hSatL_T(Tsat);
            lambdaTV = hSatV_T(TV) - hSatL_T(Tsat);
            hF = hLiq(liquidFeed,xF_dis,TF);
            hL = hLiq(liquidOut,xL_dis,TL);
            hC = hSatL_T(TS);
            HS = hSatV_T(TS);
            HV = hSatV_T(TV);

            if(obj.hasFlashFeed())
                flashFeed = obj.flashFeed();
                Flash = var(flashFeed.iFlow);
                TFlash = var(flashFeed.iTemperature);
                lambdaTFlash = hSatV_T(TC) - hSatL_T(Tsat);
            end

            % System of equations

            y(1) = S - C;
            y(2) = F - V - L;
            y(3) = F*xF_dis - L*xL_dis;
            y(4) = F*xF_tot - L*xL_tot;
            y(5) = PS - PC;
            y(6) = TV - (satT(PV) + BPR(xL_dis));
            y(7) = Q - S*(HS - hC);
            y(8) = Q + F*hF - (V*HV + L*hL);
            y(9) = TC - satT(PC);

            y = zeros(obj.numEquations(),1);
            y(1) = TC - TS;
            y(2) = TV - TL;
            y(3) = xC_dis;
            y(4) = xC_tot;
            y(5) = F - V - L;
            y(6) = S - C;
            y(7) = F*xF_dis - L*xL_dis;
            y(8) = F*xF_tot - L*xL_tot;
            y(9) = S*lambdaTS - obj.U*obj.A*(TS - TL);
            y(10) = S*lambdaTS - (V*lambdaTV + L*cp(xF_dis,TF)*(TL - TF));
%             y(10) = F*hF + S*lambdaTS - (V*HV + L*hL);

            if(obj.hasFlashFeed())
                y(1) = Flash*hSatV_T(TFlash) + S*hSatV_T(TS) - C*hSatV_T(TC);
                y(6) = Flash + S - C;
                y(9) = Flash*lambdaTFlash + S*lambdaTS - obj.U*obj.A*(TC - TL);
                y(10) = Flash*lambdaTFlash + S*lambdaTS - (V*lambdaTV + L*cp(xF_dis,TF)*(TL - TF));
%                 y(11) = TFlash - TS;
            end

            y(9) = 0.001 * y(9);
            y(10) = 0.001 * y(10);

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
