function y = gammaR(tau,rel_pi,region2CoeffsR)
    I = region2CoeffsR(:,2);
    J = region2CoeffsR(:,3);
    n = region2CoeffsR(:,4);
    nPiI = (n).*(rel_pi.^I);
    sumTerms = (nPiI).*((tau-0.5).^J);
    y = sum(sumTerms);
end