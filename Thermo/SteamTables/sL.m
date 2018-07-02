function y = sL(T,P)
    tau = 1386.0/T;
    rel_pi = P/16.53;
    y = R*(tau*gammaTau(tau,rel_pi)-gamma(tau,rel_pi));
end