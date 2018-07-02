function y = BPR(X,P)
    dT = BlackLiquor.BPRatm(X);
    Tp = Steam.satT(P);
    dTpdT = 1 + 0.6*(Tp/100.0-3.7316); % ====== CHECK! ===========
    y = dTpdT*dT;
end