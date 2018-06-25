function [GEN,FOBJ,FDE] = runFmincon(fileName,everyXGenerations,scenario)

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

while ischar(line)
    if rem(count,everyXGenerations / 10) ~= 0
        line = fgetl(f);
        count = count + 1;
        continue
    end        
    s = strsplit(line,'\t');
    disp(s(1))
    x0 = str2double(s(4:end-1));
    options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter');
    [x,fval] = fminunc(fobj,x0,options);
    
    GEN = [GEN str2double(s(1))];
    FOBJ = [FOBJ fval];
    FDE = [FDE, str2double(s(3))];

    line = fgetl(f);
    count = count + 1;
end

fclose(f);

end

