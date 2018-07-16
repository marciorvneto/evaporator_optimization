clear all, close all, clc

addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Solvers/DE');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');
addpath('../Scenarios');

scenarioName = 'nr_daniel.m';
run(scenarioName);


identifier = 'nr_daniel';

objFunName = 'nr_fobj_daniel';

maxIterations = 1e6;


minimumF = 0.4;
maximumF = 0.8;
pointsF = 3;

minimumNpop = 20;
maximumNpop = 40;
pointsNpop = 4;

minimumCR = 0.9;
maximumCR = 0.9;
pointsCR = 1;

numberTrials = 3;

logEveryXIterations = 1;

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
copyfile(['../Scenarios/',objFunName,'.m'],[pathToFolder,'/',objFunName,'.m'])


%% Create a parpool and spawn threads

% nCores = 2;
pool = parpool(nCores);

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


    F_VTR = 1e-10;
    
    %% Edit
    
    maxIterations = 5e7/Npop;
    
    
    F_VTR = -inf;
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
    S_struct.internalConvergence   = true;

    S_struct.engine = engine;
    S_struct.file = file;

   
    [FVr_x,S_y,I_nf] = deopt(objFunName,S_struct);
   
   
    fclose(file);
    
end


    fclose(file);


delete(pool);
