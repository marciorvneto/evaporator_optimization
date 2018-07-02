function y = hL(T,P,Const)
    tau = 1386.0/T;
    rel_pi = P/16.53;
    y = Const.R*T*tau*gammaTau(tau,rel_pi,Const.region1Coeffs);
end