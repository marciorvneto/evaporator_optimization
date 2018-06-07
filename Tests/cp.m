function y = cp(x,T)
%CP Summary of this function goes here
%   Detailed explanation goes here
t = T-273.16;
y = 4.216*(1-x)+(1.675 + 3.31*t/1000)*x + (4.87-20*t/1000)*(1-x)*x.^3;

end

