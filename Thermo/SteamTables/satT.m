function y = satT(P,Const)
    n = Const.satCoeffs;
    beta = P.^0.25;
    E = beta*beta + n(3)*beta + n(6);
    F = n(1)*beta*beta + n(4)*beta + n(7);
    G = n(2)*beta*beta + n(5)*beta + n(8);
    D = 2.0*G/(-F - sqrt(F*F-4.0*E*G));
    y = (n(10) + D - sqrt((n(10)+D)*(n(10)+D)-4.0*(n(9)+n(10)*D)))/2.0;

end