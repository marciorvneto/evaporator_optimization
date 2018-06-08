function y = fobj(x,engine)
%FOBJ Summary of this function goes here
%   Detailed explanation goes here
fx = engine.evaluateBalances(x,engine.handler);

y = 0.5*(fx'*fx);
end

