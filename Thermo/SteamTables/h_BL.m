function y = h_BL(X,T)
    a = 105.0;
    b = 0.300;
    tref = 80;
    tC = T - 273.15;
    hw = Steam.hLSatT(273.15 + tref);
    hmix = a*(-1 + exp(-X/b));
    dh = intCp_BL(X,tC) - intCp_BL(X,tref);
    y = hw + hmix + dh;
end