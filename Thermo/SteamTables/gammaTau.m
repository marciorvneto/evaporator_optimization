function y = gammaTau(tau,rel_pi,region1Coeffs)
    I = region1Coeffs(:,2);
    J = region1Coeffs(:,3);
    n = region1Coeffs(:,4);
    nPiI = (n).*((7.1-rel_pi).^I);
    jTauJ = (J).*((tau-1.222).^(J-1.0));
    sumTerms = (nPiI).*(jTauJ);
    y = sum(sumTerms);
end