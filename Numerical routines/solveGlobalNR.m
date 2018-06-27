function [xFinal,solved] = solveGlobalNR(fun,x0,n,rate)
%Globally convergent Newton-Raphson method

xOld = x0;
xNew = x0;
count = 0;
solved = false;

maxIter = 10;
while true
   disp(strcat('=== Iteration',num2str(count),' ==='))
   f_xOld = feval(fun,xOld);
   J = numericalJacobian(fun,n,xOld,1e-5);
   if(rcond(J)) < 1e-8
       xFinal = xNew;
       break
   end
%    if(rcond(J) < 1e-16)
%       dx = (-J'*J + 1e4*eye(n))\(J'*f_xOld); 
%    else
%        dx = (-J)\f_xOld; 
%        dx = real(backtrack(fun,x0,dx,rate));
%    end
   dx = real((-J)\f_xOld); 
%    dx = real(backtrack(fun,x0,dx,rate));
   xNew = xOld + dx;
   f_xNew = feval(fun,xNew);
   normF = f_xNew'*f_xNew;
   disp(strcat('Norm: ',num2str(normF)))
   count=count+1;
   if(count > maxIter || rcond(J) < 1e-16 || sum(isnan(xNew))>0)
%        disp('Global NR failed to converge')
       xFinal = x0;
       break
   end
   xOld=xNew;
   if(normF < n*1e-5)
       xFinal = xNew;
       solved = true;
       break
   end
end

end

function newdx = backtrack(fun,x,dx,rate)
    lambda = 1;
    count = 0;
    while true
       x_dx = x + lambda*dx;
       f_x = feval(fun,x);
       f_x_dx = feval(fun,x_dx);
       normFx = 0.5*(f_x'*f_x);
       normFx_dx = 0.5*(f_x_dx'*f_x_dx);
       if normFx_dx < normFx
           newdx = lambda*dx;
           break
       else
           lambda = lambda / rate;
       end
       if count > 10
           newdx = dx;
%            disp('Backtrack unsuccesful');
           break
       end
       count = count+1;
    end

end
