classdef Engine < handle
    %Simulator engine
    %   The actual calculations are done here

    properties
        handler;
        temperatureBounds;
        flowBounds;
        x_disBounds;
        x_totBounds;
        pressureBounds;
        QBounds;
        ABounds;
        addInfo;
    end

    methods
        function obj = Engine(handler)
           obj.handler = handler;
           obj.temperatureBounds = [273.15,600];
           obj.pressureBounds = [0,500];
           obj.flowBounds = [0,100];
           obj.x_disBounds = [0,1];
           obj.x_totBounds = [0,1];
           obj.QBounds = [0 1e6];
           obj.ABounds = [0 1e4];
        end

        function u = numUnknowns(obj,handler)
           u = 0;
           for n = 1:handler.numStreams()
              u = u + handler.numUnknownsStream(n);
           end
           for n = 1:handler.numBlocks()
              u = u + handler.numUnknownsBlock(n);
           end
        end

        function eq = numEquations(obj,handler)
           eq = 0;
           for n = 1:handler.numBlocks()
              eq = eq + handler.numEquationsBlock(n);
           end
           for n = 1:handler.numStreams()
              eq = eq + handler.numEquationsStream(n);
           end
        end

        function dof = degreesOfFreedom(obj,handler)
           dof = handler.numUnknowns() - handler.numKnown();
           for n = 1:handler.numBlocks()
              dof = dof - handler.numEquations(n);
           end
        end
        
        function [iT,iP] = vaporAndCondensateIndices(obj,handler)
            iT=[];
            iP=[];
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);                
                if(strcmp(currentStream.type,'VSTREAM') || strcmp(currentStream.type,'CSTREAM'))
                    iTemperature = currentStream.iTemperature;
                    iT=[iT iTemperature];
                    iPressure = currentStream.iPressure;
                    iP=[iP iPressure];
                end
                
            end
        end

        function y = getStreams(obj)
            y = obj.handler.streams;
        end

        function y = getBlocks(obj)
            y = obj.handler.blocks;
        end

        function y = getStream(obj,n)
            y = obj.handler.getStream(n);
        end

        function y = getBlock(obj,n)
            y = obj.handler.getBlock(n);
        end

        % =========== Setup ====================

        function obj = preallocateVariables(obj,handler)
            currentIndex = 1;
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                currentIndex = currentStream.preallocateVariables(currentIndex);
            end
            for n = 1:handler.numBlocks()
                currentBlock = handler.getBlock(n);
                currentIndex = currentBlock.preallocateVariables(currentIndex);
            end
        end

        function obj = returnVariables(obj,handler,result)
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                currentStream.fetchVariables(result);
            end
            for n = 1:handler.numBlocks()
                currentBlock = handler.getBlock(n);
                currentBlock.fetchVariables(result);
            end
        end

        function guess = transportInitialGuesses(obj,handler)
            guess = zeros(obj.numUnknowns(handler),1);
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                guess = currentStream.transportInitialGuesses(guess);
            end
        end

        function obj = loadScenario(obj,scenarioName)
            load(scenarioName);
            obj.handler = Handler();
            for n=1:length(scenario.blocks)
                obj.handler.addBlock(scenario.blocks{n});
            end
            for n=1:length(scenario.streams)
                obj.handler.addStream(scenario.streams{n});
            end
        end

        function obj = saveScenario(obj,scenarioName)
            scenario.blocks={};
            scenario.streams={};
            for n = 1:obj.handler.numBlocks()
                currentBlock = obj.handler.getBlock(n);
                scenario.blocks{end+1}=currentBlock;
            end
            for n = 1:obj.handler.numStreams()
                currentStream = obj.handler.getStream(n);
                scenario.streams{end+1}=currentStream;
            end
            save(scenarioName,'scenario');
        end

        function obj = saveInitialGuess(obj,guessName)
            obj.preallocateVariables(obj.handler);
            initialGuess = obj.transportInitialGuesses(obj.handler);
            save(guessName,'initialGuess');
        end

        function obj = loadInitialGuess(obj,guessName)
            obj.preallocateVariables(obj.handler);
            load(guessName);
            obj.returnVariables(obj.handler,initialGuess);
        end
        
        function var = solveEasy(obj,initialGuess)
            A = obj.adjacencyEasy();
            [l,u,p,q] = obj.scc(A);
            original = obj.reversePermutation(q);
            var = initialGuess;            
            for n=1:length(l)
                blockVarIndices = l(n):u(n);
                originalVarIndices = q(blockVarIndices);
%                 opt = optimoptions('fsolve','Display','Iter','TolFun', 1E-14, 'TolX', 1E-14,'MaxFunEvals',5000*length(blockVarIndices));                
                opt = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-10,'MaxFunEvals',15000*length(blockVarIndices),'Algorithm','levenberg-marquardt');                
%                 opt = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-10,'MaxFunEvals',5000*length(blockVarIndices),'Algorithm','levenberg-marquardt','ScaleProblem','jacobian');                
                blockEqIndices = l(n):u(n);
                permuteEqs = @(y) y(p);
                permuteVars = @(x) x(original);
                blockIndices = @(y) y(blockEqIndices);
                eval = @(x) obj.evaluateEasyBalances(x,obj.handler);
                
                fullSystem = @(x) eval(obj.substituteVariables(var,x,originalVarIndices));
                truncatedSystem = @(x) blockIndices(permuteEqs(fullSystem(x)));                
                [xsol,fval]=fsolve(truncatedSystem,var(originalVarIndices),opt);
                var = obj.substituteVariables(var,xsol,originalVarIndices);
            end
        end
        
        function y = originalVariables(obj,p)
           y = zeros(1,length(p));
           for n=1:length(p)
               y(p(n)) = n;
           end 
        end
        
        function y = reversePermutation(obj,p)
           y = zeros(1,length(p));
           for n=1:length(p)
               y(p(n)) = n;
           end
        end
        
        function v = substituteVariables(obj,var,x,indices)
            v = var;
            v(indices) = x;
        end

        % =========== Math ====================
%         function obj = run(obj,x0)
%            solved = false;
%            consistent = true;
% %            obj.preallocateVariables(obj.handler);
% %            initialGuess = obj.transportInitialGuesses(obj.handler);
%             initialGuess = x0;
% 
% %         
% %         function obj = run(obj,x0)
% %            solved = false;
% %            initialGuess = x0;
% %            solFcn = @(input) obj.evaluateBalances(input,obj.handler);
% %            [xResult,solved] = solveGlobalNR(solFcn,initialGuess,obj.numUnknowns(obj.handler),2);           
% %            obj.returnVariables(obj.handler,xResult);
% %            obj.generateReport(xResult,obj.handler);
% %         end
%         end
        
        function [xResult,solved] = run(obj,x0)
           initialGuess = x0;
           solFcn = @(input) obj.evaluateBalances(input,obj.handler);
           [xResult,solved] = solveGlobalNR(solFcn,initialGuess,obj.numUnknowns(obj.handler),2);           
        end

        function y = evaluateBalances(obj,var,handler)

            % Blocks

%             y = zeros(obj.numUnknowns(handler),1);
            y = [];
            start = 1;
            for n = 1:handler.numBlocks()
                currentBlock = handler.getBlock(n);
                result = currentBlock.evaluate(var);
                endY = start+length(result)-1;
                y(start:endY) = result;
                start = endY + 1;
            end

            % Fixed values

            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                result = currentStream.evaluate(var);
                endY = start+length(result)-1;
                y(start:endY) = result;
                start = endY + 1;
            end

            y = y(:);

        end

        
        function y = evaluateEasyBalances(obj,var,handler)
            
            % Blocks
            
%             y = zeros(obj.numUnknowns(handler),1);
            n = length(var);
            y = zeros(n,1);
            start = 1;
            for n = 1:handler.numBlocks()
                currentBlock = handler.getBlock(n);
                result = currentBlock.evaluateEasy(var);
                endY = start+length(result)-1;
                y(start:endY) = result;
                start = endY + 1;
            end
            
            % Fixed values
            
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                result = currentStream.evaluate(var);
                endY = start+length(result)-1;
                y(start:endY) = result;
                start = endY + 1;
            end
            
%             y = y(:);
            
        end
        
        function var = replaceFixedValues(obj,handler,var)
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                var = currentStream.replaceFixedValues(var);
            end
        end
        
        function A = adjacencyEasy(obj)
           n = obj.numUnknowns(obj.handler);
           A = zeros(n,n);
           i=1;
           for n = 1:obj.handler.numBlocks()
                currentBlock = obj.handler.getBlock(n);
                [A,i] = currentBlock.adjacencyEasy(A,i);
           end
           for n = 1:obj.handler.numStreams()
                currentStream = obj.handler.getStream(n);
                [A,i] = currentStream.adjacencyEasy(A,i);
            end
            
        end
        
        function [l,u,p,q] = scc(~,A)
            [p,q,r,~,~,~] = dmperm(A);
%             C = A(p,q);
            l=[];
            u=[];
            n = 1;
            while n<length(r)
               l = [l,r(n)]; 
               u = [u,r(n+1)-1];
%                figure(1)
%                spy(C,'k')
%                hold on
%                B = zeros(size(A));
%                B(r(n):r(n+1)-1,r(n):r(n+1)-1) = 1;
%                spy(B,'r')
%                hold off
               n=n+1;
            end            
                    
        end

        function [A,b] = linearConstraints(obj,handler)

            numUnknowns = obj.numUnknowns(handler);

            A = [];
            b = [];

            for n = 1:handler.numBlocks()
                currentBlock = handler.getBlock(n);
                [rowA,rowb] = currentBlock.linearConstraints(numUnknowns);
                A = [A;rowA];
                b = [b;rowb];
            end

            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                [rowA,rowb] = currentStream.linearConstraints(numUnknowns);
                A = [A;rowA];
                b = [b;rowb];
            end

        end

        function randomGuess = randomGuess(obj,handler)
            [lbVector,ubVector] = obj.getBounds(handler);
            randomVector = rand(obj.numUnknowns(handler),1);
            randomGuess = lbVector + (ubVector-lbVector).*randomVector;
        end

        function [lb,ub] = getBounds(obj,handler)
            lb = zeros(obj.numUnknowns(handler),1);
            ub = zeros(obj.numUnknowns(handler),1);
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                [lb,ub] = currentStream.getBounds(obj,lb,ub);
            end
            for n = 1:handler.numBlocks()
                currentBlock = handler.getBlock(n);
                [lb,ub] = currentBlock.getBounds(obj,lb,ub);
            end
        end

        function passed = consistencyCheck(obj,var,handler)
            passed = true;
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                iFlow = currentStream.iFlow;
                iTemperature = currentStream.iTemperature;
                F = var(iFlow);
                T = var(iTemperature);
                if F < 0 || T <0
                    passed = false;
                    break
                end
                if(strcmp(currentStream.type,'LSTREAM'))
                    iX_dis = currentStream.iX_dis;
                    iX_tot = currentStream.iX_tot;
                    x_dis = var(iX_dis);
                    x_tot = var(iX_tot);
                    if x_dis < -1e-6 || x_tot < -1e-6
                        passed = false;
                        break
                    end
                end
            end
        end

        function report = generateReport(obj,var,handler)
            report='';
            for n = 1:handler.numStreams()
                currentStream = handler.getStream(n);
                iFlow = currentStream.iFlow;
                iTemperature = currentStream.iTemperature;

                report = [report,'STREAM ',currentStream.name,'\n'];
                report = [report,'Flow:  ',num2str(var(iFlow)),'\n'];
                report = [report,'Temp:  ',num2str(var(iTemperature)),'\n'];

                if(strcmp(currentStream.type,'LSTREAM'))
                    iX_dis = currentStream.iX_dis;
                    iX_tot = currentStream.iX_tot;
                    report = [report,'Dissolved solids:  ',num2str(var(iX_dis)),'\n'];
                    report = [report,'Total solids:  ',num2str(var(iX_tot)),'\n'];
                end

                report = [report,'-------------------------'];
                report = [report,'\n'];

            end
            file = fopen('report.txt','w');
            fprintf(file,report);
            fclose(file);
        end

    end
end
