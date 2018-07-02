function y = gammaTauR(tau,rel_pi,region2CoeffsR)
    I = region2CoeffsR(:,2);
    J = region2CoeffsR(:,3);
    n = region2CoeffsR(:,4);
    nPiI = (n).*(rel_pi.^I);
    jTauJ = (J).*((tau-0.5).^(J-1.0));
    sumTerms = (nPiI).*(jTauJ);
    y = sum(sumTerms);
end