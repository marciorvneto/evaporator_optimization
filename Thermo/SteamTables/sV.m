function y = sV(T,P)
    tau = 540.0/T;
    rel_pi = P/1.0;
    hVRT = tau*(gammaTau0(tau)+gammaTauR(tau,rel_pi));
    sumGamma = gamma0(tau,rel_pi) + gammaR(tau,rel_pi);
    y = R*(hVRT - sumGamma);
end