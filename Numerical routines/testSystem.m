function y = testSystem(x)
%Exponential intersecting a cubic
y=zeros(2,1);
y(1) = exp(x(1))-x(2);
y(2) = x(1).^3-x(2);

end

