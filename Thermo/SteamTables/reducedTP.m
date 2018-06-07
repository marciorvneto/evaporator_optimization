function [t,p] = reducedTP(TK,PPa,Tstar,Pstar)

t = Tstar ./ TK;
p = PPa ./ Pstar;

end

