function y = gamma0(tau,rel_pi,region2Coeffs0)
    J = region2Coeffs0(:,2);
    n = region2Coeffs0(:,3);
    sumTerms = (n).*(tau.^J);
    result = sum(sumTerms);
    y = result + log(rel_pi);
end