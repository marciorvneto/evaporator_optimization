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
function S_MSE= nr_fobj(FVr_temp, S_struct)

    engine = S_struct.engine;
    
    fx = @(x) engine.evaluateBalances(x,engine.handler);
    feasy = @(x) engine.evaluateEasyBalances(x,engine.handler);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12);
    
    [xSolved,fval,exitflag,output,jacob] = fsolve(feasy,FVr_temp,op);
    if exitflag == 1
        disp('solved easy problem')
        FVr_temp = real(xSolved);
    end
    
%     [xSolved,solved] = engine.run(FVr_temp');
    
%     fx = engine.evaluateBalances(xSolved,engine.handler);
    [xSolved,fval,exitflag,output,jacob] = fsolve(fx,FVr_temp,op);
    
    fprintf(1,'Exitflag: %d\n',exitflag);
 
    S_MSE.I_nc      = 0;%no constraints
    S_MSE.FVr_ca    = 0;%no constraint array
    S_MSE.I_no      = 1;%number of objectives (costs)
    if exitflag > 0
        S_MSE.FVr_oa(1) =norm(fval);
    else
        S_MSE.FVr_oa(1) = 1e9;
        
    end
%     S_MSE.FVr_oa(1) = 0.5*(fx'*fx);
end

