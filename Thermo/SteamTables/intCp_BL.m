function y = intCp_BL(X,tC)
    y = 4.216*(1-X)*tC + (1.675*tC + 3.31/2000.0*tC*tC)*X + (4.87*tC - 10/1000.0*tC*tC)*(1-X)*X*X*X;
end