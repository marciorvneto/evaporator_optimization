function y = hSatV_T(T)

Psat = satP(T);

[t,p] = reducedTP(T,Psat,540,1e6);
h_RT = t.*(gamma_t_R2_r(t,p)+gamma_t_R2_id(t,p));

y = h_RT.*T*0.461526;

end