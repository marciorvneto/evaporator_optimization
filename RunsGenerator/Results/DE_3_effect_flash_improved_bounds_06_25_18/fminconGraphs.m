clear all, close all, clc

addpath('../../../Core');
addpath('../../../Thermo');
addpath('../../../Solvers');
addpath('../../../Thermo/SteamTables');
addpath('../../../Numerical routines');

everyXGenerations = 5000;

scenario = dir('*_scen.m');
allFiles = dir('*.result');
numFiles = length(allFiles);
for n=1:numFiles
   fileName = allFiles(n).name ;
   [gen,fobj,fde] = runFmincon(fileName,everyXGenerations,scenario);
   fig = figure('visible','off');
   plot(gen,log10(fde));
   plot(gen,log10(fobj),'.');
   title(strrep(fileName,'_','-'));
   xlabel('Generations')
   ylabel('log_{10}(f_{obj})')
   legend('DE','fminunc')
   saveas(fig,[fileName,'.png'])
   M = [gen',fobj',fde'];
   save([filename,'_graphs'],'M')
end
  