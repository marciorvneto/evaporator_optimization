clear all, close all, clc

allFiles = dir('*.result');
numFiles = length(allFiles);
for n=1:numFiles
   fileName = allFiles(n).name ;
   [gen,fobj] = parseResults(fileName);
   fig = figure('visible','off');
   converged = find(fobj<1e12);
   plot(gen(converged),fobj(converged));
   title(strrep(fileName,'_','-'));
   xlabel('Generations')
   ylabel('f_{obj}')
   saveas(fig,[fileName,'.png'])   
end
  