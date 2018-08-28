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
function S_MSE= nr_fobj_daniel_new(FVr_temp, S_struct)    

    engine = S_struct.engine; 
    
    Vout1 = engine.addInfo.Vout1;
    Vout2 = engine.addInfo.Vout2;
    
    EPAR = engine.addInfo.EPAR;
    ESER = engine.addInfo.ESER;

    BLToPar = engine.addInfo.BLToPar;
    BLToSer = engine.addInfo.BLToSer;
    
    VSpl1 = engine.addInfo.VSpl1;
    VSpl0 = engine.addInfo.VSpl0;
    LSpl3 = engine.addInfo.LSpl3;
    LSpl2 = engine.addInfo.LSpl2;
    LSpl5 = engine.addInfo.LSpl5;
    LSpl7 = engine.addInfo.LSpl7;
    VSpl9 = engine.addInfo.VSpl9;
    
    x = FVr_temp(1:end-8);
    splits = FVr_temp(end-7:end-1);
    vaporTemperature = FVr_temp(end);
    
    Vout1.temperature = vaporTemperature;
    Vout2.temperature = vaporTemperature;
    
    VSpl1.percentToFirstStream = FVr_temp(end-1);
    VSpl0.percentToFirstStream = FVr_temp(end-2);
    LSpl3.percentToFirstStream = FVr_temp(end-3);
    LSpl2.percentToFirstStream = FVr_temp(end-4);
    LSpl5.percentToFirstStream = FVr_temp(end-5);
    LSpl7.percentToFirstStream = FVr_temp(end-6);
    VSpl9.percentToFirstStream = FVr_temp(end-7);
    
    iT = S_struct.iT;
    iP = S_struct.iP;
    
    x = fixX(x,iP,iT,S_struct.constants,engine);
   
    
    fx = @(x) engine.evaluateBalances(x,engine.handler);
    feasy = @(x) engine.evaluateEasyBalances(x,engine.handler);
    
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-10,'MaxFunEvals',200*length(FVr_temp),'Algorithm','levenberg-marquardt','ScaleProblem','none');
%     op = optimoptions('fsolve','Display','Iter','TolFun', 1E-12, 'TolX', 1E-12,'MaxFunEvals',100*length(FVr_temp),'Algorithm','trust-region-dogleg');

    [xSolved,fval,exitflag,output,jacob] = fsolve(feasy,x,op);
    xSolved = real(xSolved);
    
    if exitflag <= 0
        S_MSE.I_nc      = 0;%no constraints
        S_MSE.FVr_ca    = 0;%no constraint array
        S_MSE.I_no      = 1;%number of objectives (costs)<
        S_MSE.actualValue = xSolved;
        S_MSE.FVr_oa(1) = 1e16 + 1e15*sum(xSolved<0);
        S_MSE.convergedX = [xSolved(:);splits(:);vaporTemperature];
        return
    end
    
%     op = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-12,'MaxFunEvals',200*length(FVr_temp),'Algorithm','trust-region-dogleg');
    op = optimoptions('fsolve','Display','Iter','TolFun', 1E-10, 'TolX', 1E-10,'MaxFunEvals',300*length(FVr_temp),'Algorithm','levenberg-marquardt','ScaleProblem','jacobian');
    
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
%     converged = (exitflag > 0);
    converged = (norm(fval)/length(xSolved)<1e-6);
    
    fprintf(1,'>>>>> Converged: %d | Positive: %d <<<<<<<<\n',converged,allPositive);
    
    penalty = 0;
    if ~converged
        penalty = penalty + 1e12 + norm(fx(xSolved));
    end
    penalty = penalty + 1e15*sum(xSolved<0);  
  
    A = (2*4400+5*8800)*0.00929;
    areaSer = xSolved(ESER.iA);
    areaPar = xSolved(EPAR.iA);
    flowToPar = xSolved(BLToPar.iFlow);
    flowToSer = xSolved(BLToSer.iFlow);    

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
end

function y = fixX(x,iP,iT,constants,engine)
    y = engine.replaceFixedValues(engine.handler,x);
    for n=1:length(iP)
       y(iP(n)) = satP(x(iT(n)),constants)*1000;
    end
end
