function res = solveHomotopy(fcn,n,x0,h)
%Solves a system of equation through Newton homotopy continuation

fx0 = feval(fcn,x0);
davidenkoODE = @(lambda,x) (-numericalJacobian(fcn,n,x,h))\fx0;
[t,y] = ode45(davidenkoODE,[0,1],x0);
res = y(end,:)';
end

