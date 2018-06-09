classdef Steam

  properties (Constant)
    R = 0.461526; % kJ/Kg.K
    Tc = 647.096; % K
    Pc = 22.064; % MPa
  end

  methods (Static)
    function y = hVSatT(T)
        P = Steam.satP(T);
        y = Steam.hV(T,P-0.1);
    end

    function y = hVSatP(P)
        T = Steam.satT(P);
        y = Steam.hV(T,P-0.1);
    end

    function y = hLSatT(T)
        P = Steam.satP(T);
        y = Steam.hL(T,P+0.1);
    end

    function y = hLSatP(P)
        T = Steam.satT(P);
        y = Steam.hL(T,P+0.1);
    end

    function y = gamma(tau,rel_pi)
        I = SteamCoefficients.region1Coeffs(:,2);
        J = SteamCoefficients.region1Coeffs(:,3);
        n = SteamCoefficients.region1Coeffs(:,4);
        sumTerms = (n.*((7.1-rel_pi).^I)).* ((tau-1.222).^J);
        y = sum(sumTerms);
    end

    function y = hV(T,P)
%         if (T < Steam.satT(P))
%             y = Steam.hL(T,P);
%             return;
%         else
%           tau = 540.0/T;
%           rel_pi = P/1.0;
%           y = Steam.R*T*tau*(Steam.gammaTau0(tau)+Steam.gammaTauR(tau,rel_pi));
%         end
        tau = 540.0/T;
        rel_pi = P/1.0;
        y = Steam.R*T*tau*(Steam.gammaTau0(tau)+Steam.gammaTauR(tau,rel_pi));
    end

    function y = sV(T,P)
        tau = 540.0/T;
        rel_pi = P/1.0;
        hVRT = tau*(Steam.gammaTau0(tau)+Steam.gammaTauR(tau,rel_pi));
        sumGamma = Steam.gamma0(tau,rel_pi) + Steam.gammaR(tau,rel_pi);
        y = Steam.R*(hVRT - sumGamma);
    end

    function y = hL(T,P)
        tau = 1386.0/T;
        rel_pi = P/16.53;
        y = Steam.R*T*tau*Steam.gammaTau(tau,rel_pi);
    end

    function y = sL(T,P)
        tau = 1386.0/T;
        rel_pi = P/16.53;
        y = Steam.R*(tau*Steam.gammaTau(tau,rel_pi)-Steam.gamma(tau,rel_pi));
    end

    function y = gammaTau(tau,rel_pi)
        I = SteamCoefficients.region1Coeffs(:,2);
        J = SteamCoefficients.region1Coeffs(:,3);
        n = SteamCoefficients.region1Coeffs(:,4);
        nPiI = (n).*((7.1-rel_pi).^I);
        jTauJ = (J).*((tau-1.222).^(J-1.0));
        sumTerms = (nPiI).*(jTauJ);
        y = sum(sumTerms);
    end

    function y = gamma0(tau,rel_pi)
        J = SteamCoefficients.region2Coeffs0(:,2);
        n = SteamCoefficients.region2Coeffs0(:,3);
        sumTerms = (n).*(tau.^J);
        result = sum(sumTerms);
        y = result + log(rel_pi);
    end

    function y = gammaTau0(tau)
        J = SteamCoefficients.region2Coeffs0(:,2);
        n = SteamCoefficients.region2Coeffs0(:,3);
        jTauJ = (J).*(tau.^(J-1.0));
        sumTerms = (n).*(jTauJ);
        y = sum(sumTerms);
    end

    function y = gammaR(tau,rel_pi)
        I = SteamCoefficients.region2CoeffsR(:,2);
        J = SteamCoefficients.region2CoeffsR(:,3);
        n = SteamCoefficients.region2CoeffsR(:,4);
        nPiI = (n).*(rel_pi.^I);
        sumTerms = (nPiI).*((tau-0.5).^J);
        y = sum(sumTerms);
    end

    function y = gammaTauR(tau,rel_pi)
        I = SteamCoefficients.region2CoeffsR(:,2);
        J = SteamCoefficients.region2CoeffsR(:,3);
        n = SteamCoefficients.region2CoeffsR(:,4);
        nPiI = (n).*(rel_pi.^I);
        jTauJ = (J).*((tau-0.5).^(J-1.0));
        sumTerms = (nPiI).*(jTauJ);
        y = sum(sumTerms);
    end

    function y = satP(T)
        n = SteamCoefficients.satCoeffs;
        theta = T + n(9)/(T-n(10));
        A = theta*theta + n(1)*theta + n(2);
        B = n(3)*theta*theta + n(4)*theta + n(5);
        C = n(6)*theta*theta + n(7)*theta + n(8);
        y = ((2.0*C)/(-B + sqrt(B*B-4.0*A*C))).^4.0;
        
    end

    function y = satT(P)
        n = SteamCoefficients.satCoeffs;
        beta = P.^0.25;
        E = beta*beta + n(3)*beta + n(6);
        F = n(1)*beta*beta + n(4)*beta + n(7);
        G = n(2)*beta*beta + n(5)*beta + n(8);
        D = 2.0*G/(-F - sqrt(F*F-4.0*E*G));
        y = (n(10) + D - sqrt((n(10)+D)*(n(10)+D)-4.0*(n(9)+n(10)*D)))/2.0;

    end

  end

end


