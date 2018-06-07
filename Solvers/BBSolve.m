classdef BBSolve < handle
    %A Newton-based branch and bound solver for hard problems
    
    properties
        tol;
        extraCriteria;
    end
    
    methods
        function obj = BBSolve(tol)
            obj.tol = tol;
            obj.extraCriteria = @(x) true;
        end        
        function [result,ok] = solve(obj,fun,numEquations,domain,Aeq,beq)
            options = optimoptions('fmincon','Algorithm','sqp');
            passed = false;
            solved = false;
            ok = false;
            fFeasibility = zeros(numEquations,1);            
            queue = PriorityQueue();
            queue.add(domain);            
            delta0 = domain.ub-domain.lb;
            while(~solved || ~passed)
                solved = false;
                passed = false;
                currentNode = queue.pop(delta0);
                currentPoint = currentNode.centerPoint();
                V = max((currentNode.ub-currentNode.lb)./delta0);
                disp(V)
                if(V < obj.tol)
                    xResult = currentPoint*0;
                    ok = false;
                    break
                end
                [~,~,feasible,~] = linprog(fFeasibility,[],[],Aeq,beq,currentNode.lb,currentNode.ub);
                if(feasible == 1)
                    quad = @(x) 0.5*(feval(fun,x)'*feval(fun,x));
                    [xResult,fVal,flag,output] = fmincon(quad,currentPoint,[],[],Aeq,beq,currentNode.lb,currentNode.ub);
                    if(flag == 1)
                        solved = true;
                    end
                    disp(strcat('Minimum: ',num2str(fVal)));
%                     [xResult,solved] = solveGlobalNR(fun,currentPoint,numEquations,2);
                    
                    if(solved)
                        passed = feval(obj.extraCriteria,xResult);
                        ok = passed && solved;
                        if(ok)
                            break
                        end
                    end                    
                    [n1,n2] = currentNode.partition();
                    queue.add(n1);
                    queue.add(n2);
                else
                    disp(' ======= Node fathomed ==========')
                end
            end
            result = xResult;
        end
    end
    
end

