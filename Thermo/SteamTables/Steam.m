classdef Steam

  properties
    R = 0.461526; % kJ/Kg.K
    Tc = 647.096; % K
    Pc = 22.064; % MPa
  end

  methods (Static)
    function y = cp(X,tC)
      y = 4.216*(1.0-X) + (1.675 + 3.31*(tC/1000.0))*X + (4.87 - 20*tC/1000.0)*(1-X)*X*X*X;
    end

  end

end




class Steam:


    function y = hVSatT(T)
        P = Steam.satP(T);
        y = Steam.hV(T,P-0.001);
    end

    function y = hVSatP(P)
        T = Steam.satT(P);
        y = Steam.hV(T,P-0.001);
    end

    function y = hLSatT(T)
        P = Steam.satP(T);
        y = Steam.hL(T,P+0.001);
    end

    function y = hLSatP(P)
        T = Steam.satT(P);
        y = Steam.hL(T,P+0.001);
    end

    function y = gamma(tau,pi)
        I = SteamCoefficients.region1Coeffs(:,1);
        J = SteamCoefficients.region1Coeffs(:,2);
        n = SteamCoefficients.region1Coeffs(:,3);
        sumTerms = (n.*((7.1-pi).^I)).* ((tau-1.222).^J);
        y = sum(sumTerms);
    end

    function y = hV(T,P)
        if (T < Steam.satT(P))
            y = Steam.hL(T,P);
            return;
        else
          tau = 540.0/T;
          pi = P/1.0;
          y = Steam.R*T*tau*(Steam.gammaTau0(tau)+Steam.gammaTauR(tau,pi));
        end
    end

    function y = sV(T,P)
        tau = 540.0/T
        pi = P/1.0
        hVRT = tau*(Steam.gammaTau0(tau)+Steam.gammaTauR(tau,pi))
        sumGamma = Steam.gamma0(tau,pi) + Steam.gammaR(tau,pi)
        y = Steam.R*(hVRT - sumGamma)
    end

    function y = hL(T,P)
        tau = 1386.0/T
        pi = P/16.53
        y = Steam.R*T*tau*Steam.gammaTau(tau,pi)
    end

    function y = sL(T,P)
        tau = 1386.0/T
        pi = P/16.53
        y = Steam.R*(tau*Steam.gammaTau(tau,pi)-Steam.gamma(tau,pi))
    end

    function y = gammaTau(tau,pi)
        I = SteamCoefficients.region1Coeffs(:,1)
        J = SteamCoefficients.region1Coeffs(:,2)
        n = SteamCoefficients.region1Coeffs(:,3)
        nPiI = (n).*((7.1-pi).^I)
        jTauJ = (J).*((tau-1.222).^(J-1.0))
        sumTerms = (nPiI).*(jTauJ)
        y = sum(sumTerms)
    end

    function y = gamma0(tau,pi)
        J = SteamCoefficients.region2Coeffs0(:,1)
        n = SteamCoefficients.region2Coeffs0(:,2)
        sumTerms = (n).*(tau.^J)
        result = sum(sumTerms)
        y = result + np.log(pi)
    end

    function y = gammaTau0(tau)
        J = SteamCoefficients.region2Coeffs0(:,1)
        n = SteamCoefficients.region2Coeffs0(:,2)
        jTauJ = (J).*(tau.^(J-1.0))
        sumTerms = (n).*(jTauJ)
        y = sum(sumTerms)
    end

    function y = gammaR(tau,pi)
        I = SteamCoefficients.region2CoeffsR(:,1)
        J = SteamCoefficients.region2CoeffsR(:,2)
        n = SteamCoefficients.region2CoeffsR(:,3)
        nPiI = (n).*(pi.^I)
        sumTerms = (nPiI).*((tau-0.5).^J)
        y = sum(sumTerms)
    end

    function y = gammaTauR(tau,pi)
        I = SteamCoefficients.region2CoeffsR(:,1)
        J = SteamCoefficients.region2CoeffsR(:,2)
        n = SteamCoefficients.region2CoeffsR(:,3)
        nPiI = (n).*(pi.^I)
        jTauJ = (J).*((tau-0.5).^(J-1.0))
        sumTerms = (nPiI).*(jTauJ)
        y = sum(sumTerms)
    end

    function y = satP(T)
        n = SteamCoefficients.satCoeffs
        theta = T + n(8)/(T-n(9))
        A = theta*theta + n(0)*theta + n(1)
        B = n(2)*theta*theta + n(3)*theta + n(4)
        C = n(5)*theta*theta + n(6)*theta + n(7)
        y = ((2.0*C)/(-B + sqrt(B*B-4.0*A*C))).^4.0
    end

    function y = satT(P)
        n = SteamCoefficients.satCoeffs
        beta = P.^0.25
        E = beta*beta + n(2)*beta + n(5)
        F = n(0)*beta*beta + n(3)*beta + n(6)
        G = n(1)*beta*beta + n(4)*beta + n(7)
        D = 2.0*G/(-F - sqrt(F*F-4.0*E*G))
        y = (n(9) + D - sqrt((n(9)+D)*(n(9)+D)-4.0*(n(8)+n(9)*D)))/2.0
    end


% print(Steam.satT(0.1))
% print(Steam.satT(1))
% print(Steam.satT(10))
