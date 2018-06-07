function y = h_TP(T,P)

Psat = satP(T);

if(P>=Psat)
    [t,p] = reducedTP(T,P,1386,16.53e6);
    h_RT = t*gamma_t_R1(t,p);
else
    [t,p] = reducedTP(T,P,540,1e6);
    h_RT = t*(gamma_t_R2_r(t,p)+gamma_t_R2_id(t,p));
end


y = h_RT*T*0.461526;

end