function y = cp_BL(X,tC)
    % Cp in Kj/Kg.K
    y = 4.216*(1.0-X) + (1.675 + 3.31*(tC/1000.0))*X + (4.87 - 20*tC/1000.0)*(1-X)*X*X*X;
end