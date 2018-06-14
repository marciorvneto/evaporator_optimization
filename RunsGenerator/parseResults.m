function [gen,fobj] = parseResults(fileName)

f = fopen(fileName,'r');

line = fgetl(f); % Cores
line = fgetl(f); % Header
line = fgetl(f);

gen = [];
fobj = [];

while ischar(line)
    s = strsplit(line,'\t');
    gen = [gen, str2double(s(1))];
    fobj = [fobj, str2double(s(3))];
    line = fgetl(f);
end

fclose(f);

end

