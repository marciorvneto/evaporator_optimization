classdef BlackLiquor

  methods (Static)

    function y = cp(X,tC)
        % Cp in Kj/Kg.K
        y = 4.216*(1.0-X) + (1.675 + 3.31*(tC/1000.0))*X + (4.87 - 20*tC/1000.0)*(1-X)*X*X*X;
    end

    function y = h(X,T)
        a = 105.0;
        b = 0.300;
        tref = 80;
        tC = T - 273.15;
        hw = Steam.hLSatT(273.15 + tref);
        hmix = a*(-1 + exp(-X/b));
        dh = BlackLiquor.intCp(X,tC) - BlackLiquor.intCp(X,tref);
        y = hw + hmix + dh;
    end

    function y = intCp(X,tC)
        y = 4.216*(1-X)*tC + (1.675*tC + 3.31/2000.0*tC*tC)*X + (4.87*tC - 10/1000.0*tC*tC)*(1-X)*X*X*X;
    end

    function y = BPRatm(X)
        y = 6.173*X-7.48*X*sqrt(X)+32.747*X*X;
    end

    function y = BPR(X,P)
        dT = BlackLiquor.BPRatm(X);
        Tp = Steam.satT(P);
        dTpdT = 1 + 0.6*(Tp/100.0-3.7316); % ====== CHECK! ===========
        y = dTpdT*dT;
    end

  end

end
