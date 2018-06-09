function y = fobj(x,engine)
%FOBJ Summary of this function goes here
%   Detailed explanation goes here
fx = engine.evaluateBalances(x,engine.handler);

% y=max(abs(fx));
% y = 1000 * norm(fx);
y = 0.5*(fx'*fx);
end

