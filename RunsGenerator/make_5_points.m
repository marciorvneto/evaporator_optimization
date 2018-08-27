clear all, close all, clc

addpath('../Core');
addpath('../Thermo');
addpath('../Solvers');
addpath('../Solvers/DE');
addpath('../Thermo/SteamTables');
addpath('../Numerical routines');
addpath('../Scenarios');

% scenarioName = 'nr_esa_series_or_parallel_correction_nocmixer.m';
% run(scenarioName);
% 
% identifier = 'FIVE_POINTS_FIXING_X_nr_esa_series_or_parallel_correction_nocmixer';
% 
% objFunName = 'nr_fobj_nr_esa_series_or_parallel';

scenarioName = 'nr_three_effect_esa_improved_bounds_scen.m';
run(scenarioName);

identifier = 'nr_three_effect_esa_improved_bounds_scen';

objFunName = 'nr_fobj_nr_template_3_effects_2_flashes';

% maxIterations = 1e6;
maxNFE = 5000;


minimumF = 0.4;
maximumF = 0.8;
pointsF = 2;

minimumNpop = 10;
maximumNpop = 20;
pointsNpop = 2;

minimumCR = 0.9;
maximumCR = 0.9;
pointsCR = 1;

numberTrials = 1;

logEveryXIterations = 1;

% nCores = feature('numcores');

%% Generate all possible combinations

allF = linspace(minimumF,maximumF,pointsF);
allNpop = linspace(minimumNpop,maximumNpop,pointsNpop);
allCR = linspace(minimumCR,maximumCR,pointsCR);
allTrials = 1:numberTrials;

scenarios = combvec(allF,allNpop,allCR,allTrials)';
scenarios = [scenarios;(minimumF+maximumF)/2,(minimumNpop+maximumNpop)/2,(minimumCR+maximumCR)/2,1];


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

nCores = 2;
% pool = parpool(nCores);
fprintf(1,'\nnumScenarios = %10.2f \n',numScenarios);

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
    
    maxIterations = ceil(maxNFE/Npop);
    
    
    F_VTR = -inf;
    I_D = length(lb);
    FVr_minbound = lb';
    FVr_maxbound = ub';
    
%     FVr_minbound =[3.931445e+02	1.080919e+01	1.984495e+02	3.178694e+02	4.821343e+01	2.043489e-01	2.033495e-01	3.931496e+02	1.081000e+01	1.984495e+02	3.821621e+02	1.139794e+01	3.762879e+01	3.931432e+02	6.256169e-01	1.984495e+02	3.654155e+02	4.565619e+00	2.527672e-01	2.530587e-01	3.631235e+02	5.245578e+00	7.006209e+01	3.712027e+02	1.139946e+01	3.762880e+01	3.789309e+02	2.023419e+01	4.865960e-01	4.920918e-01	3.131600e+02	5.000000e+01	1.994386e-01	1.993343e-01	3.654209e+02	4.154649e+01	2.374081e-01	2.364550e-01	3.757461e+02	6.204484e-01	3.762879e+01	3.654155e+02	1.518080e+00	7.006209e+01	6.405375e+02	5.245887e+00	7.006209e+01	3.757461e+02	1.956859e+00	3.421979e-01	3.485625e-01	3.931600e+02	6.255767e-01	1.984495e+02	3.739099e+02	3.101929e+01	3.178736e-01	3.156329e-01	3.757461e+02	1.005600e+01	3.417934e-01	3.477307e-01	3.712948e+02	6.158482e-01	3.762880e+01	3.817626e+02	1.015473e+01	3.762877e+01	3.642729e+02	1.135992e+01	9.671849e+01	3.654155e+02	5.150003e+00	7.006209e+01	3.700041e+02	1.056880e+01	9.671849e+01	3.642730e+02	4.672061e-02	9.671849e+01	3.712948e+02	1.282290e-02	3.762880e+01	3.738970e+02	1.067918e+01	3.205402e-01	3.225105e-01	3.757461e+02	8.099199e+00	3.431105e-01	3.520177e-01	3.931600e+02	1.143553e+01	1.984495e+02	3.654155e+02	1.786214e+00	6.946017e+01	3.131600e+02	6.351742e+00	1.972349e-01	1.972904e-01	3.131600e+02	4.364796e+01	2.007943e-01	2.001197e-01	3.719076e+02	2.230019e+01	3.167408e-01	3.152731e-01	3.654155e+02	6.666325e+00	7.006209e+01	3.712971e+02	6.042063e-01	3.762880e+01	3.631109e+02	1.047222e+01	7.006209e+01	3.738977e+02	1.053019e+01	9.671836e+01	3.817782e+02	1.213595e+01	5.829633e-01	5.829143e-01	3.728299e+02	1.056972e+01	9.671837e+01	3.738968e+02	2.033934e+01	3.158786e-01	3.149598e-01	3.712971e+02	1.020346e+01	3.762880e+01	3.631109e+02	1.005771e-01	7.006209e+01	1.051741e+01	1.372159e+03	6.408527e+01	2.390574e+04	1.764815e+01	5.375025e+03	6.408557e+01	2.549633e+04	6.408540e+01	2.401153e+04	7.722840e-01	8.053090e-01	1.270403e-01	5.473634e-02	3.442578e-01	3.654155e+02]*0.9;
%     FVr_maxbound =[3.931445e+02	1.080919e+01	1.984495e+02	3.178694e+02	4.821343e+01	2.043489e-01	2.033495e-01	3.931496e+02	1.081000e+01	1.984495e+02	3.821621e+02	1.139794e+01	3.762879e+01	3.931432e+02	6.256169e-01	1.984495e+02	3.654155e+02	4.565619e+00	2.527672e-01	2.530587e-01	3.631235e+02	5.245578e+00	7.006209e+01	3.712027e+02	1.139946e+01	3.762880e+01	3.789309e+02	2.023419e+01	4.865960e-01	4.920918e-01	3.131600e+02	5.000000e+01	1.994386e-01	1.993343e-01	3.654209e+02	4.154649e+01	2.374081e-01	2.364550e-01	3.757461e+02	6.204484e-01	3.762879e+01	3.654155e+02	1.518080e+00	7.006209e+01	6.405375e+02	5.245887e+00	7.006209e+01	3.757461e+02	1.956859e+00	3.421979e-01	3.485625e-01	3.931600e+02	6.255767e-01	1.984495e+02	3.739099e+02	3.101929e+01	3.178736e-01	3.156329e-01	3.757461e+02	1.005600e+01	3.417934e-01	3.477307e-01	3.712948e+02	6.158482e-01	3.762880e+01	3.817626e+02	1.015473e+01	3.762877e+01	3.642729e+02	1.135992e+01	9.671849e+01	3.654155e+02	5.150003e+00	7.006209e+01	3.700041e+02	1.056880e+01	9.671849e+01	3.642730e+02	4.672061e-02	9.671849e+01	3.712948e+02	1.282290e-02	3.762880e+01	3.738970e+02	1.067918e+01	3.205402e-01	3.225105e-01	3.757461e+02	8.099199e+00	3.431105e-01	3.520177e-01	3.931600e+02	1.143553e+01	1.984495e+02	3.654155e+02	1.786214e+00	6.946017e+01	3.131600e+02	6.351742e+00	1.972349e-01	1.972904e-01	3.131600e+02	4.364796e+01	2.007943e-01	2.001197e-01	3.719076e+02	2.230019e+01	3.167408e-01	3.152731e-01	3.654155e+02	6.666325e+00	7.006209e+01	3.712971e+02	6.042063e-01	3.762880e+01	3.631109e+02	1.047222e+01	7.006209e+01	3.738977e+02	1.053019e+01	9.671836e+01	3.817782e+02	1.213595e+01	5.829633e-01	5.829143e-01	3.728299e+02	1.056972e+01	9.671837e+01	3.738968e+02	2.033934e+01	3.158786e-01	3.149598e-01	3.712971e+02	1.020346e+01	3.762880e+01	3.631109e+02	1.005771e-01	7.006209e+01	1.051741e+01	1.372159e+03	6.408527e+01	2.390574e+04	1.764815e+01	5.375025e+03	6.408557e+01	2.549633e+04	6.408540e+01	2.401153e+04	7.722840e-01	8.053090e-01	1.270403e-01	5.473634e-02	3.442578e-01	3.654155e+02]*1.1;
    
    
    
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
%     S_struct.iT = iT;
%     S_struct.iP = iP;
%     S_struct.constants = constants;
    S_struct.file = file;

   
    [FVr_x,S_y,I_nf] = deopt(objFunName,S_struct);
   
   
    fclose(file);
    
end


    fclose(file);


delete(pool);
