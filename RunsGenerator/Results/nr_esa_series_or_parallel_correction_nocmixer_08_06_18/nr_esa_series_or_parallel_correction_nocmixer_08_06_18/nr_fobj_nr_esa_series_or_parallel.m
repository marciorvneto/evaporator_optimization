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
function S_MSE= nr_fobj_nr_esa_series_or_parallel(FVr_temp, S_struct)    

    engine = S_struct.engine; 
    
    Vout1 = engine.addInfo.Vout1;
    Vout2 = engine.addInfo.Vout2;
    
    E0 = engine.addInfo.E0;
    EPAR = engine.addInfo.EPAR;
    ESER = engine.addInfo.ESER;

    BLToPar = engine.addInfo.BLToPar;
    BLToSer = engine.addInfo.BLToSer;
    
    LSpl1 = engine.addInfo.LSpl1;
    VSpl0 = engine.addInfo.VSpl0;    
    LSpl3 = engine.addInfo.LSpl3;
    LSpl2 = engine.addInfo.LSpl2;
    VSpl4 = engine.addInfo.VSpl4;
    
    x = FVr_temp(1:end-6);
    splits = FVr_temp(end-5:end-1);
    vaporTemperature = FVr_temp(end);
    
    Vout1.temperature = vaporTemperature;
    Vout2.temperature = vaporTemperature;
    LSpl1.percentToFirstStream = FVr_temp(end-1);
    VSpl0.percentToFirstStream = FVr_temp(end-2);
    LSpl3.percentToFirstStream = FVr_temp(end-3);
    LSpl2.percentToFirstStream = FVr_temp(end-4);
    VSpl4.percentToFirstStream = FVr_temp(end-5);
    
%     LSpl1.percentToFirstStream = 0.5;
%     VSpl0.percentToFirstStream = 0.5;
%     LSpl3.percentToFirstStream = 0.5;
%     LSpl2.percentToFirstStream = 0;
%     VSpl4.percentToFirstStream = 0;    
  
    
    
    
    fx = @(x) engine.evaluateBalances(x,engine.handler);
    feasy = @(x) engine.evaluateEasyBalances(x,engine.handler);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12,'MaxFunEvals',200*length(FVr_temp));

    [xSolved,fval,exitflag,output,jacob] = fsolve(fx,x,op);
    xSolved = real(xSolved);
    
    fprintf(1,'Exitflag: %d\n',exitflag);    
    
 
    S_MSE.I_nc      = 0;%no constraints
    S_MSE.FVr_ca    = 0;%no constraint array
    S_MSE.I_no      = 1;%number of objectives (costs)
    S_MSE.actualValue = xSolved;
    
    penalty = 0;
    if exitflag <= 0
        penalty = penalty + 1e15;
    end
    penalty = penalty + 1e12*sum(xSolved<0);
  
    numEvaps = 3;
    
    originalArea = xSolved(E0.iA);
    areaSer = xSolved(ESER.iA);
    areaPar = xSolved(EPAR.iA);
    flowToPar = xSolved(BLToPar.iFlow);
    flowToSer = xSolved(BLToSer.iFlow);
    A = numEvaps * originalArea;
    if flowToPar > 0.01
        A = A + areaPar;
    end
    if flowToSer > 0.01
        A = A + areaSer;
    end
    cost = 30000 +1000*A^0.9;
    
    if (sum(xSolved<0)) < 1 && (exitflag > 0)
        S_MSE.FVr_oa(1) = cost;
    else
        S_MSE.FVr_oa(1) = penalty;
    end
   
    
    S_MSE.convergedX = [xSolved(:);splits(:);vaporTemperature];
%     S_MSE.FVr_oa(1) = 0.5*(fx'*fx);
end

