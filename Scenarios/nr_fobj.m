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
    
    Vout = engine.addInfo.Vout;
    Vin = engine.addInfo.Vin;
    
    VSpl = engine.addInfo.VSpl;
    LSpl = engine.addInfo.LSpl;
    
    VSpl.percentToFirstStream = FVr_temp(end);
    LSpl.percentToFirstStream = FVr_temp(end-1);
    
    VToNewEvap = engine.addInfo.VToNewEvap;
    
    Evap = engine.addInfo.Evap;
    
    x = FVr_temp(1:end-2);
    splits = FVr_temp(end-1:end);
    
    
    fx = @(x) engine.evaluateBalances(x,engine.handler);
    feasy = @(x) engine.evaluateEasyBalances(x,engine.handler);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12);
    
    [xSolved,fval,exitflag,output,jacob] = fsolve(feasy,x,op);
    if exitflag > 0
        disp('solved easy problem')
        FVr_temp = real(xSolved);
    end
    

    [xSolved,fval,exitflag,output,jacob] = fsolve(fx,x,op);
    
    fprintf(1,'Exitflag: %d\n',exitflag);    
    
 
    S_MSE.I_nc      = 0;%no constraints
    S_MSE.FVr_ca    = 0;%no constraint array
    S_MSE.I_no      = 1;%number of objectives (costs)
    S_MSE.actualValue = real(xSolved);
    if exitflag > 0
        flowToNewEvap = xSolved(VToNewEvap.iFlow);
        if flowToNewEvap < 0.01
            n = 3;
        else
            n = 4;
        end
        area = n*xSolved(Evap.iA);  
        cost = 10000 +324*area^0.91;
        S_MSE.FVr_oa(1) = cost;
%         S_MSE.FVr_oa(1) =norm(fval);
    else
        S_MSE.FVr_oa(1) = 1e12;
        
    end
    S_MSE.convergedX = real([xSolved(:);splits(:)]);
%     S_MSE.FVr_oa(1) = 0.5*(fx'*fx);
end

