%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function:         S_MSE= objfun(FVr_temp, S_struct)
% Author:           Rainer Storn
% Description:      Implements the cost function to be minimized.
% Parameters:       FVr_temp     (I)    Paramter vector
%                   S_Struct     (I)    Contains a variety of parameters.
%                                       For details see Rundeopt.m
% Return value:     S_MSE.I_nc   (O)    Number of constraints
%                   S_MSE.FVr_ca (O)    Constraint values. 0 means the constraints
%                                       are met. Values > 0 measure the distance
%                                       to a particular constraint.
%                   S_MSE.I_no   (O)    Number of objectives.
%                   S_MSE.FVr_oa (O)    Objective function values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S_MSE= nr_fobj_nr_template_3_effects_2_flashes(FVr_temp, S_struct)    

    engine = S_struct.engine;
    
    fx = @(x) engine.evaluateBalances(x,engine.handler);
    feasy = @(x) engine.evaluateEasyBalances(x,engine.handler);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-10,'MaxFunEvals',200*length(FVr_temp),'Algorithm','levenberg-marquardt','ScaleProblem','jacobian');
    
%     [xSolved,fval,exitflag,output,jacob] = fsolve(feasy,FVr_temp,op);
%     if exitflag > 0
%         disp('solved easy problem')
%         FVr_temp = real(xSolved);
%     end
    [xSolved,fval,exitflag,output,jacob] = fsolve(feasy,FVr_temp,op);
    
    if exitflag <= 0
        S_MSE.I_nc      = 0;%no constraints
        S_MSE.FVr_ca    = 0;%no constraint array
        S_MSE.I_no      = 1;%number of objectives (costs)
        S_MSE.actualValue = real(xSolved);
        S_MSE.convergedX = real(xSolved(:));
        S_MSE.FVr_oa(1) = 1e12;
        return
    end
    
    [xSolved,fval,exitflag,output,jacob] = fsolve(fx,xSolved,op);
    
%     G = @(x,l) l*fx(x) + (1-l)*feasy(x);
%     
%     L = linspace(0,1,10);
%     L = L(2:end);
%         op = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-10,'MaxFunEvals',50*length(FVr_temp),'Algorithm','levenberg-marquardt','ScaleProblem','jacobian');    
%     for l=L
%         g = @(x) G(x,l);
%         [xSolved,fval,exitflag,output,jacob] = fsolve(g,xSolved,op);
%     end
    
    
    
    fprintf(1,'Exitflag: %d\n',exitflag);
    
    if sum(real(xSolved)>0) == length(xSolved)
        allPositive = true;
    else
        allPositive = false;
    end
    
 
    S_MSE.I_nc      = 0;%no constraints
    S_MSE.FVr_ca    = 0;%no constraint array
    S_MSE.I_no      = 1;%number of objectives (costs)
    S_MSE.actualValue = real(xSolved);
    if exitflag > 0 && allPositive
        S_MSE.FVr_oa(1) =norm(fval);
    else
        S_MSE.FVr_oa(1) = 1e12;
        
    end
    S_MSE.convergedX = real(xSolved(:));
%     S_MSE.FVr_oa(1) = 0.5*(fx'*fx);
end

