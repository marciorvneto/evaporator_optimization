clear all, close all, clc

addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Solvers/DE');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');
addpath('../Scenarios');

scenarioName = 'nr_three_effect_esa_improved_bounds_scen.m';
run(scenarioName);


identifier = 'nr_DE_3_effect_flash_improved_bounds';

maxIterations = 1e6;

minimumF = 0.4;
maximumF = 0.6;
pointsF = 3;

minimumNpop = 3*52;
maximumNpop = 5*52;
pointsNpop = 3;

minimumCR = 0.9;
maximumCR = 0.9;
pointsCR = 1;

numberTrials = 3;

logEveryXIterations = 100;

% nCores = feature('numcores');

%% Generate all possible combinations

allF = linspace(minimumF,maximumF,pointsF);
allNpop = linspace(minimumNpop,maximumNpop,pointsNpop);
allCR = linspace(minimumCR,maximumCR,pointsCR);
allTrials = 1:numberTrials;

scenarios = combvec(allF,allNpop,allCR,allTrials)';
numScenarios = size(scenarios,1);

%% Create results folder

folderName = [identifier,'_',datestr(now,'mm_dd_yy')];
pathToFolder = ['./Results/',folderName];
mkdir(pathToFolder);

copyfile('makeGraphs.m', [pathToFolder,'/makeGraphs.m']);
copyfile('parseResults.m', [pathToFolder,'/parseResults.m']);

copyfile('fminconGraphs.m', [pathToFolder,'/fminconGraphs.m']);
copyfile('runFmincon.m', [pathToFolder,'/runFmincon.m']);

copyfile(['../Scenarios/',scenarioName],[pathToFolder,'/',scenarioName])


%% Create a parpool and spawn threads

nCores = 12;
% pool = parpool(nCores);

for i=1:numScenarios
    
    S_struct = struct;
    
    F = scenarios(i,1);
    Npop = scenarios(i,2);
    CR = scenarios(i,3);
    trial = scenarios(i,4);
    
    fileName = ['Npop_',num2str(Npop),'_F_',num2str(F),'_CR_',num2str(CR),'_Trial_',num2str(trial)];
    filePath = [pathToFolder,'/',fileName,'.result'];
    file = fopen(filePath,'w');
    fprintf(file,'Running on %d cores\n',nCores);
    fprintf(file,'Npop\tF\tCR\tTrial\n');
    fprintf(file,'%d\t%e\t%e\t%d\n',Npop,F,CR,trial);
    fprintf(file,'Lower bounds\n');
    for n=1:(length(lb)-1)
        fprintf(file,'%e\t',lb(n));
    end
    fprintf(file,'\n');
    fprintf(file,'Upper bounds\n');
    for n=1:(length(ub)-1)
        fprintf(file,'%e\t',ub(n));
    end
    fprintf(file,'\n');
    fprintf(file,'Iteration\tNumberFeval\tfobj\tBest\n');
    fclose(file);
    file = fopen(filePath,'a');
    
    %% Edit
    
    maxIterations = 5e7/Npop;
    
    
    F_VTR = 1e-8;
    I_D = length(lb);
    FVr_minbound = lb'; 
    FVr_maxbound = ub'; 
    I_bnd_constr = 1;
    I_NP = Npop; 
	I_itermax = maxIterations; 
	F_weight = F; 
	F_CR = CR;
    I_strategy = 1;
    I_refresh = logEveryXIterations;
    I_plotting = 0;
    
    S_struct.I_NP         = I_NP;
    S_struct.F_weight     = F_weight;
    S_struct.F_CR         = F_CR;
    S_struct.I_D          = I_D;
    S_struct.FVr_minbound = FVr_minbound;
    S_struct.FVr_maxbound = FVr_maxbound;
    S_struct.I_bnd_constr = I_bnd_constr;
    S_struct.I_itermax    = I_itermax;
    S_struct.F_VTR        = F_VTR;
    S_struct.I_strategy   = I_strategy;
    S_struct.I_refresh    = I_refresh;
    S_struct.I_plotting   = I_plotting;
    
    S_struct.engine = engine;
    S_struct.file = file;
    
    [FVr_x,S_y,I_nf] = deopt('nr_fobj',S_struct);
   
   
    fclose(file);
    
end

% delete(pool);



