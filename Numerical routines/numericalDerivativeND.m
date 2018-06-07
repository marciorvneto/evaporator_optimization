function dfdx = numericalDerivativeND(fcn,x0,nvars,ivar,h)

hvec = zeros(nvars,1);
hvec(ivar)=h;

x0_plus_h = x0 + hvec;
x0_minus_h = x0 - hvec;

dfdx = (feval(fcn,x0_plus_h)-feval(fcn,x0_minus_h))/(2*h);

end