function y = satP(T,Const)
    n = Const.satCoeffs;
    theta = T + n(9)/(T-n(10));
    A = theta*theta + n(1)*theta + n(2);
    B = n(3)*theta*theta + n(4)*theta + n(5);
    C = n(6)*theta*theta + n(7)*theta + n(8);
    y = ((2.0*C)/(-B + sqrt(B*B-4.0*A*C))).^4.0;

end