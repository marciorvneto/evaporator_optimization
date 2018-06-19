clear all, close all, clc

addpath('../../../Core');
addpath('../../../Thermo');
addpath('../../../Solvers');
addpath('../../../Thermo/SteamTables');
addpath('../../../Numerical routines');

everyXGenerations = 5000;
numCores = 2;

pool = parpool(numCores);

scenario = dir('*_scen.m');
allFiles = dir('*.result');
numFiles = length(allFiles);
parfor n=1:numFiles
   fileName = allFiles(n).name ;
   [filepath,name,ext] = fileparts(fileName);
   foutName = [name,'_fminunc'];
   [gen,fobj,fde] = runFmincon(fileName,everyXGenerations,scenario,[foutName,'.txt']);
   fig = figure('visible','off');
   plot(gen,log10(fde));
   hold on
   plot(gen,log10(fobj),'.');
   title(strrep(fileName,'_','-'));
   xlabel('Generations')
   ylabel('log_{10}(f_{obj})')
   legend('DE','fminunc')
   saveas(fig,[foutName,'.png'])
end

delete(pool);