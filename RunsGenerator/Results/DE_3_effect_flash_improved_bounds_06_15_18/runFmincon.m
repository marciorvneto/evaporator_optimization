function [GEN,FOBJ,FDE] = runFmincon(fileName,everyXGenerations,scenario,foutName)

f = fopen(fileName,'r');

run(scenario.name)

fobj = @(x) 0.5*(fun(x)'*fun(x));

line = fgetl(f); % Cores
line = fgetl(f); % Npop, F, CR header
line = fgetl(f); % Npop F CR
line = fgetl(f); % lb header
line = fgetl(f); % lb
line = fgetl(f); % ub header
line = fgetl(f); % ub
line = fgetl(f);
line = fgetl(f);

GEN = [];
FOBJ = [];
FDE = [];

count = 0;


fout = fopen(foutName,'w');


while ischar(line)
    if rem(count,everyXGenerations / 10) ~= 0
        line = fgetl(f);
        count = count + 1;
        continue
    end
    s = strsplit(line,'\t');
    if str2double(s(3)) > 1e-2
        line = fgetl(f);
        count = count + 1;
        continue
    end
    
    disp(s(1))
    x0 = str2double(s(4:end-1));
    options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter','MaxFunctionEvaluations',1000*length(lb));
%     options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter','MaxFunctionEvaluations',3);
    [x,fval] = fminunc(fobj,x0,options);
    
    fprintf(fout,'%f\t%f\t%f\n',str2double(s(1)),fval,str2double(s(3)));
    
    GEN = [GEN str2double(s(1))];
    FOBJ = [FOBJ fval];
    FDE = [FDE, str2double(s(3))];
    
    

    line = fgetl(f);
    count = count + 1;
end
fclose(fout);
fclose(f);

end

