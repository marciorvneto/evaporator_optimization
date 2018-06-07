function J = numericalJacobian(fcn,n,x0,h)
    J = zeros(n,n);
%     for i=1:n
%        for j=1:n
%            derivative = numericalDerivativeND(fcn,x0,n,j,h);
%            J(i,j) = derivative(i);
%            
%        end
%     end

    for j=1:n       
        derivative = numericalDerivativeND(fcn,x0,n,j,h);
        J(:,j) = derivative;
    end

end