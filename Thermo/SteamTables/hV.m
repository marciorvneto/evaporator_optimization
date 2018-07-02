function y = hV(T,P,Const)
%         if (T < satT(P))
%             y = hL(T,P);
%             return;
%         else
%           tau = 540.0/T;
%           rel_pi = P/1.0;
%           y = R*T*tau*(gammaTau0(tau)+gammaTauR(tau,rel_pi));
%         end
    tau = 540.0/T;
    rel_pi = P/1.0;
    y = Const.R*T*tau*(gammaTau0(tau,Const.region2Coeffs0)+gammaTauR(tau,rel_pi,Const.region2CoeffsR));
end