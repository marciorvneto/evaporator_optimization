clear all, close all, clc

allFiles = dir('*.result');
numFiles = length(allFiles);
for n=1:numFiles
   fileName = allFiles(n).name ;
   [gen,fobj] = runFmincon(fileName);
   fig = figure('visible','off');
   plot(gen,log10(fobj));
   title(strrep(fileName,'_','-'));
   xlabel('Generations')
   ylabel('log_{10}(f_{obj})')
   saveas(fig,[fileName,'.png'])   
end
  