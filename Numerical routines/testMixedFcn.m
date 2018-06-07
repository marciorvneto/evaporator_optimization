function y = testMixedFcn(x)

y(1) = 3*x(1) - x(2) + 6;
y(2) = 3*x(1).^2 - 3*x(2) + 7*x(3);
y(3) = x(1).*x(2) + 7*x(3);

end

