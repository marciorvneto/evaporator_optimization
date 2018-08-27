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
    
    iT = S_struct.iT;
    iP = S_struct.iP;
    
    x = fixX(x,iP,iT,S_struct.constants);
    
%     LSpl1.percentToFirstStream = 0.5;
%     VSpl0.percentToFirstStream = 0.5;
%     LSpl3.percentToFirstStream = 0.5;
%     LSpl2.percentToFirstStream = 0;
%     VSpl4.percentToFirstStream = 0;    
  
%     for n=1:length(iP)
%        x(iT(n)) = satT(x(iP(n))/1000,S_struct.constants);
%     end
    
    
    
    fx = @(x) engine.evaluateBalances(x,engine.handler);
    feasy = @(x) engine.evaluateEasyBalances(x,engine.handler);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12,'MaxFunEvals',100*length(FVr_temp),'Algorithm','levenberg-marquardt');
%     op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12,'MaxFunEvals',100*length(FVr_temp),'Algorithm','trust-region-dogleg');

    [xSolved,fval,exitflag,output,jacob] = fsolve(feasy,x,op);
    xSolved = real(xSolved);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12,'MaxFunEvals',200*length(FVr_temp),'Algorithm','trust-region-dogleg');
    
    try
        [xSolved,fval,exitflag,output,jacob] = fsolve(fx,xSolved,op);
    catch
        [xSolved,fval,exitflag,output,jacob] = fsolve(fx,x,op);
    end
    xSolved = real(xSolved);
    
    fprintf(1,'Exitflag: %d\n',exitflag);    
    
 
    S_MSE.I_nc      = 0;%no constraints
    S_MSE.FVr_ca    = 0;%no constraint array
    S_MSE.I_no      = 1;%number of objectives (costs)
    S_MSE.actualValue = xSolved;
    
    allPositive = (sum(xSolved<0) < 1);
    converged = (exitflag > 0);
    
    fprintf(1,'>>>>> Converged: %d | Positive: %d <<<<<<<<\n',converged,allPositive);
    
    penalty = 0;
    if ~converged
        penalty = penalty + 1e12 + norm(fx(xSolved));
    end
    penalty = penalty + 1e15*sum(xSolved<0);    
    
  
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
    
%     S_MSE.FVr_oa(1) = abs(cost) + penalty;
    
    if allPositive && converged
        S_MSE.FVr_oa(1) = cost;
    else
        S_MSE.FVr_oa(1) = penalty;
    end
    
    fprintf(1,'Fobj: %e\n', S_MSE.FVr_oa(1));
   
    
    S_MSE.convergedX = [xSolved(:);splits(:);vaporTemperature];
%     S_MSE.FVr_oa(1) = 0.5*(fx'*fx);
end

function y = fixX(x,iP,iT,constants)
    y=x;
    for n=1:length(iP)
       y(iT(n)) = satT(x(iP(n))/1000,constants);
    end
end