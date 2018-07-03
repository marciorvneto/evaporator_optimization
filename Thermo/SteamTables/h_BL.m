function y = h_BL(X,T,Const)
    a = 105.0;
    b = 0.300;
    tref = 80;
    tC = T - 273.15;
    hw = hLSatT(273.15 + tref,Const);
    hmix = a*(-1 + exp(-X/b));
    dh = intCp_BL(X,tC) - intCp_BL(X,tref);
    y = hw + hmix + dh;
end