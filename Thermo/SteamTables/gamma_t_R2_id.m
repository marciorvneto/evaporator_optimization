function y = gamma_t_R2_id(t,p)

data = [0	-9.69276865
1	10.08665597
-5	-0.005608791
-4	0.071452738
-3	-0.407104982
-2	1.424081917
-1	-4.383951132
2	-0.284086325
3	0.021268464];

J = data(:,1);
n = data(:,2);

res=0;

for i=1:9
   res=res + n(i)*J(i).*t.^(J(i)-1);
end

y=res;
end

