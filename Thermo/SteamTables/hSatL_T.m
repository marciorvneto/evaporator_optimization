function y = hSatL_T(T)

Psat = satP(T);

[t,p] = reducedTP(T,Psat,1386,16.53e6);
h_RT = t.*gamma_t_R1(t,p);

y = h_RT.*T*0.461526;

end