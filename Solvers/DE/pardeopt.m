%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function:         [FVr_bestmem,S_bestval,I_nfeval] = deopt(fname,S_struct)
%
% Author:           Rainer Storn, Ken Price, Arnold Neumaier, Jim Van Zandt
% Description:      Minimization of a user-supplied function with respect to x(1:I_D),
%                   using the differential evolution (DE) algorithm.
%                   DE works best if [FVr_minbound,FVr_maxbound] covers the region where the
%                   global minimum is expected. DE is also somewhat sensitive to
%                   the choice of the stepsize F_weight. A good initial guess is to
%                   choose F_weight from interval [0.5, 1], e.g. 0.8. F_CR, the crossover
%                   probability constant from interval [0, 1] helps to maintain
%                   the diversity of the population but should be close to 1 for most.
%                   practical cases. Only separable problems do better with CR close to 0.
%                   If the parameters are correlated, high values of F_CR work better.
%                   The reverse is true for no correlation.
%
%                   The number of population members I_NP is also not very critical. A
%                   good initial guess is 10*I_D. Depending on the difficulty of the
%                   problem I_NP can be lower than 10*I_D or must be higher than 10*I_D
%                   to achieve convergence.
%
%                   deopt is a vectorized variant of DE which, however, has a
%                   property which differs from the original version of DE:
%                   The random selection of vectors is performed by shuffling the
%                   population array. Hence a certain vector can't be chosen twice
%                   in the same term of the perturbation expression.
%                   Due to the vectorized expressions deopt executes fairly fast
%                   in MATLAB's interpreter environment.
%
% Parameters:       fname        (I)    String naming a function f(x,y) to minimize.
%                   S_struct     (I)    Problem data vector (must remain fixed during the
%                                       minimization). For details see Rundeopt.m.
%                   ---------members of S_struct----------------------------------------------------
%                   F_VTR        (I)    "Value To Reach". deopt will stop its minimization
%                                       if either the maximum number of iterations "I_itermax"
%                                       is reached or the best parameter vector "FVr_bestmem"
%                                       has found a value f(FVr_bestmem,y) <= F_VTR.
%                   FVr_minbound (I)    Vector of lower bounds FVr_minbound(1) ... FVr_minbound(I_D)
%                                       of initial population.
%                                       *** note: these are not bound constraints!! ***
%                   FVr_maxbound (I)    Vector of upper bounds FVr_maxbound(1) ... FVr_maxbound(I_D)
%                                       of initial population.
%                   I_D          (I)    Number of parameters of the objective function.
%                   I_NP         (I)    Number of population members.
%                   I_itermax    (I)    Maximum number of iterations (generations).
%                   F_weight     (I)    DE-stepsize F_weight from interval [0, 2].
%                   F_CR         (I)    Crossover probability constant from interval [0, 1].
%                   I_strategy   (I)    1 --> DE/rand/1
%                                       2 --> DE/local-to-best/1
%                                       3 --> DE/best/1 with jitter
%                                       4 --> DE/rand/1 with per-vector-dither
%                                       5 --> DE/rand/1 with per-generation-dither
%                                       6 --> DE/rand/1 either-or-algorithm
%                   I_refresh     (I)   Intermediate output will be produced after "I_refresh"
%                                       iterations. No intermediate output will be produced
%                                       if I_refresh is < 1.
%
% Return value:     FVr_bestmem      (O)    Best parameter vector.
%                   S_bestval.I_nc   (O)    Number of constraints
%                   S_bestval.FVr_ca (O)    Constraint values. 0 means the constraints
%                                           are met. Values > 0 measure the distance
%                                           to a particular constraint.
%                   S_bestval.I_no   (O)    Number of objectives.
%                   S_bestval.FVr_oa (O)    Objective function values.
%                   I_nfeval         (O)    Number of function evaluations.
%
% Note:
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 1, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. A copy of the GNU
% General Public License can be obtained from the
% Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FVr_bestmem,S_bestval,I_nfeval] = pardeopt(fname,S_struct)

convcrit = 0.000000000001;


% if (matlabpool('size')>0)
%     delete(gcp);
% end
% matlabpool('open',16);
pool=parpool(16);
popdev = fopen('population_hist.txt','w');   % re-write possible former file
fprintf(popdev,'Population development history file\n');
fclose (popdev);

%-----This is just for notational convenience and to keep the code uncluttered.--------
I_NP         = S_struct.I_NP;
F_weight     = S_struct.F_weight;
F_CR         = S_struct.F_CR;
I_D          = S_struct.I_D;
FVr_minbound = S_struct.FVr_minbound;
FVr_maxbound = S_struct.FVr_maxbound;
FVr_discr    = S_struct.FVr_discr;
I_bnd_constr = S_struct.I_bnd_constr;
I_itermax    = S_struct.I_itermax;
F_VTR        = S_struct.F_VTR;
I_strategy   = S_struct.I_strategy;
I_refresh    = S_struct.I_refresh;
I_plotting   = S_struct.I_plotting;
StallGenLim  = S_struct.StallGenLim;

FVr_cont     = (FVr_discr - 0.5) < 0; 
discr_mask   = repmat(FVr_discr,I_NP,1);
cont_mask    = repmat(FVr_cont,I_NP,1);

%-----Check input variables---------------------------------------------

if (I_NP < 5)
    I_NP=5;
    fprintf(1,' I_NP increased to minimal value 5\n');
end
if ((F_CR < 0) | (F_CR > 1))
    F_CR=0.5;
    fprintf(1,'F_CR should be from interval [0,1]; set to default value 0.5\n');
end
if (I_itermax <= 0)
    I_itermax = 200;
    fprintf(1,'I_itermax should be > 0; set to default value 200\n');
end
I_refresh = floor(I_refresh);

if (I_strategy==6)
    P_F = F_CR;
end

%-----Initialize population and some arrays-------------------------------
FM_pop = zeros(I_NP,I_D); %initialize FM_pop to gain speed

FVr_range = FVr_maxbound-FVr_minbound;
FVr_rangeC = cont_mask.*repmat(FVr_range,I_NP,1);
FVr_rangeD = discr_mask.*repmat(FVr_range,I_NP,1);
%FM_popC(:, find(sum(abs(FM_popC)) == 0)) = [];
converged=zeros(I_D); 

%----FM_pop is a matrix of size I_NPx(I_D+1). It will be initialized------
%----with random values between the min and max values of the-------------
%----parameters-----------------------------------------------------------

for k=1:I_NP
    FM_pop(k,:) = FVr_minbound + rand(1,I_D).*(FVr_maxbound - FVr_minbound);
end

FM_popold     = zeros(size(FM_pop));    % toggle population
FVr_bestmem   = zeros(1,I_D);           % best population member ever
FVr_bestmemit = zeros(1,I_D);           % best population member in iteration
I_nfeval      = 0;                      % number of function evaluations

%------Evaluate the best member after initialization----------------------

I_best_index   = 1;                     % start with first population member
S_val(1)       = feval(fname,FM_pop(I_best_index,:),S_struct);
F_val(1)       = S_val(1).FVr_oa;

S_bestval = S_val(1);                   % best objective function value so far
F_bestval = S_val(1).FVr_oa;           	% best objective function value so far
I_nfeval  = I_nfeval + 1;
for k=2:I_NP                            % check the remaining members
    S_val(k)  = feval(fname,FM_pop(k,:),S_struct);
    F_val(k)  = S_val(k).FVr_oa;
    I_nfeval  = I_nfeval + 1;
    %if (left_win(S_val(k),S_bestval) == 1)
    if (F_val(k) < F_bestval)
        fprintf(1,'\n %15.3f < %15.3f \n', S_val(k).FVr_oa , S_bestval.FVr_oa);
        I_best_index   = k;             % save its location
        S_bestval      = S_val(k);
        F_bestval      = F_val(k);
    end
end
FVr_bestmemit = FM_pop(I_best_index,:); % best member of current iteration
S_bestvalit   = S_bestval;              % best value of current iteration

FVr_bestmem = FVr_bestmemit;        	% best member ever

%------DE-Minimization---------------------------------------------
%------FM_popold is the population which has to compete. It is--------
%------static through one iteration. FM_pop is the newly--------------
%------emerging population.----------------------------------------

FM_pm1   = zeros(I_NP,I_D);             % initialize population matrix 1
FM_pm2   = zeros(I_NP,I_D);             % initialize population matrix 2
FM_pm3   = zeros(I_NP,I_D);             % initialize population matrix 3
FM_pm4   = zeros(I_NP,I_D);             % initialize population matrix 4
FM_pm5   = zeros(I_NP,I_D);             % initialize population matrix 5
FM_ps    = zeros(I_NP,I_D);             % initialize sorted pop. matrix
FM_bm    = zeros(I_NP,I_D);             % initialize FVr_bestmember  matrix
FM_ui    = zeros(I_NP,I_D);             % intermediate population of perturbed vectors
FM_mui   = zeros(I_NP,I_D);             % mask for intermediate population
FM_mpo   = zeros(I_NP,I_D);             % mask for old population
FVr_rot  = (0:1:I_NP-1);                % rotating index array (size I_NP)
FVr_rotd = (0:1:I_D-1);                 % rotating index array (size I_D)
FVr_rt   = zeros(I_NP);                 % another rotating index array
FVr_rtd  = zeros(I_D);                  % rotating index array for exponential crossover
FVr_a1   = zeros(I_NP);                 % index array
FVr_a2   = zeros(I_NP);                 % index array
FVr_a3   = zeros(I_NP);                 % index array
FVr_a4   = zeros(I_NP);                 % index array
FVr_a5   = zeros(I_NP);                 % index array
FVr_ind  = zeros(4);

FM_meanv = ones(I_NP,I_D);

convhist = fopen('convhist.txt','w');
fprintf(convhist,'F_weight: %f,  F_CR: %f,  I_NP: %d\n\n',F_weight,F_CR,I_NP);
fclose(convhist);
popdev = fopen('population_hist.txt','w');
fprintf(popdev,'Population history.\nF_weight: %f,  F_CR: %f,  I_NP: %d\n\n',F_weight,F_CR,I_NP);
fclose(popdev);

I_iter = 1;
BestFTemp=ones(1,I_NP).*(10^12);
S_BestvalTemp = repmat(S_bestval,1,I_NP);
BestVectTemp=zeros(I_NP,I_D);

q = max( ceil(0.15*I_NP), 5);                   % for MDE_pBX only
if (I_strategy==11)
    q_fr = F_weight;    % when q, p fixed and F, CR adaptive in MDE_pBX
    p_fr = F_CR;        % p calculated in the if section of adaptive MDE_pBX
    q = max( min(I_NP, ceil(q_fr*I_NP)), 2);
    %p calculated in the if section of adaptive MDE_pBX
end
CRm = 0.7;                                      % for MDE_pBX only
Fm = 0.5;                                       % for MDE_pBX only
goodCR = [];                                    % for MDE_pBX only
goodF = [];                                     % for MDE_pBX only
%[F_vs, ind_sorted] = sort(F_val);               % for MDE_pBX only

 done=0;       
%while ((I_iter < I_itermax) & (S_bestval.FVr_oa(1) > F_VTR))
StallGen=0;
while (done==0)
    StallGen = StallGen+1;
    FM_popold = FM_pop;                         % save the old population
    S_struct.FM_pop = FM_pop;
    S_struct.FVr_bestmem = FVr_bestmem;
    
    goodCRind = zeros(I_NP);                 	% for MDE_pBX only
    goodFind = zeros(I_NP);                   	% for MDE_pBX only
    [F_vs, ind_sorted] = sort(F_val);        	% for MDE_pBX only
    for k=1:I_NP
        FM_ps(k,:)=FM_pop(ind_sorted(k),:);     % for MDE_pBX only: generate sorted pop.
 	end
    
    FVr_ind = randperm(4);                      % index pointer array
    
    FVr_a1  = randperm(I_NP);                   % shuffle locations of vectors
    FVr_rt  = rem(FVr_rot+FVr_ind(1),I_NP);     % rotate indices by ind(1) positions
    FVr_a2  = FVr_a1(FVr_rt+1);                 % rotate vector locations
    FVr_rt  = rem(FVr_rot+FVr_ind(2),I_NP);
    FVr_a3  = FVr_a2(FVr_rt+1);
    FVr_rt  = rem(FVr_rot+FVr_ind(3),I_NP);
    FVr_a4  = FVr_a3(FVr_rt+1);
    FVr_rt  = rem(FVr_rot+FVr_ind(4),I_NP);
    FVr_a5  = FVr_a4(FVr_rt+1);
    
    FM_pm1 = FM_popold(FVr_a1,:);               % shuffled population 1
    FM_pm2 = FM_popold(FVr_a2,:);               % shuffled population 2
    FM_pm3 = FM_popold(FVr_a3,:);               % shuffled population 3
    FM_pm4 = FM_popold(FVr_a4,:);               % shuffled population 4
    FM_pm5 = FM_popold(FVr_a5,:);               % shuffled population 5
    
    for k=1:I_NP                                % population filled with the best member
        FM_bm(k,:) = FVr_bestmemit;             % of the last iteration
    end
    
    FM_mui = rand(I_NP,I_D) < F_CR;  % all random numbers < F_CR are 1, 0 otherwise
    
    %---------- only if using adaptive scheme of MDE_pBX --------------
    if ((I_strategy == 7) || (I_strategy==8))   % for non-adaptive MDE_pBX versions
        F = repmat(F_weight,I_NP,1);
        CR = repmat(F_CR,I_NP,1);
    end
    if ((I_strategy == 9) || (I_strategy==10))  % only if using adaptive scheme of MDE_pBX
        if I_iter > 1 && ~isempty(goodCR) && sum(goodF) > 0
            CRm = (0.9+0.001*abs(randn))*CRm + 0.1*(1+0.001*abs(randn))*((sum(goodCR.^1.5)/length(goodCR))^(1/1.5));
            if( mean(F) < 0.85 )
                Fm = (0.9+0.01*abs(randn))*Fm + 0.1*(1+0.01*abs(randn))*((sum(goodF.^1.5)/length(goodF))^(1/1.5));    %power mean
            else
                Fm = (0.8+0.01*abs(randn))*Fm + 0.1*(1+0.01*abs(randn))*((sum(goodF.^1.5)/length(goodF))^(1/1.5));   %power mean
            end
        end
        [F, CR] = FCRgeneration(I_NP, CRm, 0.1, Fm,  0.1);
    end
    if  (I_strategy == 7)                       % for MDE_pBX without parent selection 
        FM_mui = rand(I_NP,I_D) < CR(:,ones(1,I_D));        
    end
        
    FM_mpo = FM_mui < 0.5;    % inverse mask to FM_mui
    
    %----Insert this if you want exponential crossover.----------------
    %FM_mui = sort(FM_mui');	  % transpose, collect 1's in each column
    %for k  = 1:I_NP
    %  n = floor(rand*I_D);
    %  if (n > 0)
    %     FVr_rtd     = rem(FVr_rotd+n,I_D);
    %     FM_mui(:,k) = FM_mui(FVr_rtd+1,k); %rotate column k by n
    %  end
    %end
    %FM_mui = FM_mui';			  % transpose back
    %----End: exponential crossover------------------------------------
    
    
    if (I_strategy == 1)                                % DE/rand/1
        FM_ui = FM_pm3 + F_weight*(FM_pm1 - FM_pm2); 	% differential variation
        FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;      % crossover
        FM_origin = FM_pm3;
    elseif (I_strategy == 2)                            % DE/local-to-best/1
        FM_ui = FM_popold + F_weight*(FM_bm-FM_popold) + F_weight*(FM_pm1 - FM_pm2);
        FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;
        FM_origin = FM_popold;
    elseif (I_strategy == 3)                            % DE/best/1 with jitter
        FM_ui = FM_bm + (FM_pm1 - FM_pm2).*((1-0.9999)*rand(I_NP,I_D)+F_weight);
        FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;
        FM_origin = FM_bm;
    elseif (I_strategy == 4)                            % DE/rand/1 with per-vector-dither
        f1 = ((1-F_weight)*rand(I_NP,1)+F_weight);
        for k=1:I_D
            FM_pm5(:,k)=f1;
        end
        FM_ui = FM_pm3 + (FM_pm1 - FM_pm2).*FM_pm5;     % differential variation
        FM_origin = FM_pm3;
        FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;      % crossover
    elseif (I_strategy == 5)                            % DE/rand/1 with per-vector-dither
        f1 = ((1-F_weight)*rand+F_weight);
        FM_ui = FM_pm3 + (FM_pm1 - FM_pm2)*f1;          % differential variation
        FM_origin = FM_pm3;
        FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;      % crossover
    elseif (I_strategy == 6)                            % either-or-algorithm
        if (rand < P_F);                                % Pmu = 0.5
            FM_ui = FM_pm3 + F_weight*(FM_pm1 - FM_pm2);% differential variation
            FM_origin = FM_pm3;
        else                                            % use F-K-Rule: K = 0.5(F+1)
            FM_ui = FM_pm3 + 0.5*(F_weight+1.0)*(FM_pm1 + FM_pm2 - 2*FM_pm3);
            FM_origin = FM_pm3;
        end
    elseif ((I_strategy >= 7) && (I_strategy <= 10))  	% MDE_pBX
        %s=randperm(NP);
        BestGr_FVr = zeros(1,I_D);
        BestGr_FVr_oa =10^10;
        
        for k=1:q
            FVr_poprand(k,:)=FM_pop(FVr_a5(k),:);
            valrand(k)=S_val(FVr_a5(k)).FVr_oa;
            if (valrand(k) < BestGr_FVr_oa)
                BestGr_FVr_oa = S_val(FVr_a5(k)).FVr_oa;
                BestGr_FVr = FVr_poprand(k,:);
                % BestGr_S_val = S_val(FVr_a5(k));
            end
        end
        FM_BestGr = repmat(BestGr_FVr,I_NP,1);
        % FM_vi = FM_pm1 + F_weight * (FM_BestGr - FM_pm1 + FM_pm2 - FM_pm3);
        FM_vi = FM_pm1 + F(:,ones(1,I_D)) .* (FM_BestGr - FM_pm1 + FM_pm2 - FM_pm3);
        
        if ((I_strategy == 7) || (I_strategy == 10))  
            FM_ui = FM_popold.*FM_mpo + FM_vi.*FM_mui;     % crossover            

        elseif ((I_strategy == 8) || (I_strategy == 9))   
            p = ceil((I_NP/2) * (1 - (I_iter-1)/I_itermax));	% regular MDE_pBX: crossover becomes greedier as search goes on  

            for k=1:I_NP
                donor = max(1,ceil(p*rand));
                cr_mask = rand(1,I_D) < CR(k);
                if (sum(cr_mask)==0)                                % if all params from donor, ensure 
                    cr_mask(max(1,min(I_D,(ceil(rand*I_D))))) = 1;  % at least one always from mutant
                end
                cr_invmask = (cr_mask - 0.5) < 0;                
                FM_ui(k,:) = FM_ps(donor,:).*cr_invmask + FM_vi(k,:).*cr_mask;     % crossover
            end
        elseif (I_strategy == 11)
            p = max(1, min(I_NP, ceil(p_fr*I_NP)));             % fixed fraction participate in crossover
            for k=1:I_NP
                donor = max(1,ceil(p*rand));
                cr_mask = rand(1,I_D) < CR(k);
                if (sum(cr_mask)==0)                                % if all params from donor, ensure 
                    cr_mask(max(1,min(I_D,(ceil(rand*I_D))))) = 1;  % at least one always from mutant
                end
                cr_invmask = (cr_mask - 0.5) < 0;                
                FM_ui(k,:) = FM_ps(donor,:).*cr_invmask + FM_vi(k,:).*cr_mask;     % crossover
            end
        else            
            fprintf(1,'\n\n\n   wwwiddusaatana!!  \n\n\n');
            break;
        end
    else
        fprintf(1,'\n\n\n   wwwiddusaatana!!  \n\n\n');
        break;
    end
    
    
    %-----Optional parent+child selection-----------------------------------------
    
    %-----Select which vectors are allowed to enter the new population------------
    
    %=====Only use this if boundary constraints are needed==================
    for k=1:I_NP
        if (I_bnd_constr == 1)
            %          for j=1:I_D %---boundary constraints via random reset-----
            %             if ( (FM_ui(k,j) > FVr_maxbound(j)) || (FM_ui(k,j) < FVr_minbound(j)) )
            %                FM_ui(k,j) = rand*(FVr_maxbound(j)-FVr_minbound(j)) +FVr_minbound(j);
            %             end
            %          end
            for j=1:I_D %----boundary constraints via bounce back-------
                if (FM_ui(k,j) > FVr_maxbound(j))
                    FM_ui(k,j) = FVr_maxbound(j) + rand*(FVr_maxbound(j) - FM_ui(k,j));
                end
                if (FM_ui(k,j) < FVr_minbound(j))
                    FM_ui(k,j) = FVr_minbound(j) + rand*(FVr_minbound(j) - FM_ui(k,j));
                end
            end
        end
    end % for k=1:I_NP
    %=====End boundary constraints==========================================
    
    
    
    %     for k=1:I_NP
    StGen=repmat(StallGen,I_NP,1);
    parfor k=1:I_NP
        
        S_tempval = feval(fname,FM_ui(k,:),S_struct);       % check cost of competitor
        I_nfeval  = I_nfeval + 1;                           % ...
        if (S_tempval.FVr_oa < S_val(k).FVr_oa)             % if (left_win(S_tempval,S_val(k)) == 1)
            FM_pop(k,:) = FM_ui(k,:);                       % replace old vector with new one (for new iteration)
            S_val(k)   = S_tempval;                         % save value in "cost array"
            
            if (I_strategy==8)                              % for MDE_pBX only
                goodCRind(k)=1;                             % for MDE_pBX only
                goodFind(k)=1;                              % for MDE_pBX only
            end
            
            %----we update S_bestval only in case of success to save time-----------
            if (S_tempval.FVr_oa < S_bestval.FVr_oa) % if (left_win(S_tempval,S_bestval) == 1)
                BestFTemp(k) = S_tempval.FVr_oa(1);
                S_BestvalTemp(k) = S_tempval;
                BestVectTemp(k,:) = FM_ui(k,:);         	% new best parameter vector ever
                StGen(k)=0;
                %S_bestval = S_tempval;                     % new best value
                %FVr_bestmem = FM_ui(k,:);                  % new best parameter vector ever
            end
        end
    end % for k = 1:NP
    StallGen = min(StGen);
    
    if (I_strategy==8)                                      % for MDE_pBX only
        goodCR=CR(goodCRind==1);                         	% for MDE_pBX only
        goodF=F(goodFind==1);                               % for MDE_pBX only
    end
    
    
    [bestF,BestIndex] = min(BestFTemp);
    S_bestval = S_BestvalTemp(BestIndex);
    FVr_bestmem = BestVectTemp(BestIndex,:);
    FVr_bestmemit = FVr_bestmem;       % freeze the best member of this iteration for the coming
    % iteration. This is needed for some of the strategies.
    
    %----Output section----------------------------------------------------------
    
  if (I_refresh > 0)
     if ((rem(I_iter,I_refresh) == 0) | I_iter == 1)
        %MY ADDITIONS
        fprintf(S_struct.file,'%d\t%d\t%e\t',I_iter,I_nfeval,S_bestval.FVr_oa(1));
        if S_struct.internalConvergence
            for n=1:I_D
              fprintf(S_struct.file,'%e\t',S_bestval.convergedX(n));
            end
        else
            for n=1:I_D
              fprintf(S_struct.file,'%e\t',FVr_bestmem(n));
            end
        end
       fprintf(S_struct.file,'\n');
        
       fprintf(1,'Iteration: %d,  Best: %e,  F_weight: %f,  F_CR: %f,  I_NP: %d\n',I_iter,S_bestval.FVr_oa(1),F_weight,F_CR,I_NP);
       %var(FM_pop)
       format long e;
       for n=1:I_D
          fprintf(1,'best(%d) = %g\n',n,FVr_bestmem(n));
       end
       if (I_plotting == 1)
          PlotIt(FVr_bestmem,I_iter,S_struct); 
       end
    end
  end
  
  %if (rem(I_iter,3) == 1)
  %   pause;
  %end
  
  I_iter = I_iter + 1;
    
  delete(gcp);
end %---end while ((I_iter < I_itermax) ...


function [F CR] = FCRgeneration(NP, CRm, CRsigma, Fm,  Fsigma)
 
 
% generation of CR
CR = CRm + CRsigma * randn(NP, 1);
CR = min(1, max(0, CR));                % set between 0 and 1


% generation of F
F = Cauchy(NP, 1, Fm, Fsigma);
F = min(1, F);                          % truncated to 1


pos = find(F<=0);
while ~ isempty(pos)
    F(pos) = Cauchy(length(pos), 1, Fm, Fsigma);
    F = min(1, F);                      % truncated to 1
    pos = find(F<=0);
end

function result = Cauchy(m, n, mu, delta)
result = mu + delta*tan(pi*( rand(m,n) - 0.5 ));

