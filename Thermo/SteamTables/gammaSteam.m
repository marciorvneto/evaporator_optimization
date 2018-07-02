function y = gammaSteam(tau,rel_pi,region1Coeffs)
    I = region1Coeffs(:,2);
    J = region1Coeffs(:,3);
    n = region1Coeffs(:,4);
    sumTerms = (n.*((7.1-rel_pi).^I)).* ((tau-1.222).^J);
    y = sum(sumTerms);
end