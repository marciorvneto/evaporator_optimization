function dfdx = numericalDerivative(fcn,x0,h)

dfdx = (feval(fcn,x0+h)-feval(fcn,x0-h))/(2*h);

end