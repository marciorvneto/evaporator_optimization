function y = gammaTau0(tau,region2Coeffs0)
    J = region2Coeffs0(:,2);
    n = region2Coeffs0(:,3);
    jTauJ = (J).*(tau.^(J-1.0));
    sumTerms = (n).*(jTauJ);
    y = sum(sumTerms);
end