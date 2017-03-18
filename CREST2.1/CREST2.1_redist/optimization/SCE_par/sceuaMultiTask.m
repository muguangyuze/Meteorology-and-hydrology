%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bestx,bestf,BESTX,BESTF] = sceuaMultiTask(x0,bl,bu,...
                                    maxn,kstop,pcento,peps,ngs,iseed,iniflg,...
                                    funcWM,funcWS,funcAct,simObj,nParal,logFile)
% This is the subroutine implementing the SCE algorithm, 
% written by Q.Duan, 9/2004
% modified by X.Shen 5/2014 to implement parallel computation
%% input parameters
% Definition:
%  x0 = the initial parameter array at the start;
%     = the optimized parameter array at the end;
%  f0 = the objective function value corresponding to the initial parameters
%     = the objective function value corresponding to the optimized parameters
%  bl = the lower bound of the parameters
%  bu = the upper bound of the parameters
%  iseed = the random seed number (for repetetive testing purpose)
%  iniflg = flag for initial parameter array (=1, included it in initial
%           population; otherwise, not included)
% func: function handle or an array of function handles. 
%       the number of func indicates the number of parallel tasks, n performed
%       in this algorithm.It is recommended to be the number of
%       processors (cores) but can be larger.
%       the func must be able to handle multi-set of input arguments when n>1, which
%       means it's a wrapper of the actual function. This wrapper partition
%       the input parameter groups into single ones and calls the actual function using every 
%       set in a non-parallel loop

%  ngs = number of complexes (sub-populations)
%  npg = number of members in a complex 
%  nps = number of members in a simplex
%  nspl = number of evolution steps for each complex before shuffling
%  mings = minimum number of complexes required during the optimization process
%  maxn = maximum number of function evaluations allowed during optimization
%  kstop = maximum number of evolution loops before convergency
%  percento = the percentage change allowed in kstop loops before convergency

% LIST OF LOCAL VARIABLES
%    x(.,.) = coordinates of points in the population
%    xf(.) = function values of x(.,.)
%    xx(.) = coordinates of a single point in x
%    cx(.,.) = coordinates of points in a complex
%    cf(.) = function values of cx(.,.)
%    s(.,.) = coordinates of points in the current simplex
%    sf(.) = function values of s(.,.)
%    bestx(.) = best point at current shuffling loop
%    bestf = function value of bestx(.)
%    worstx(.) = worst point at current shuffling loop
%    worstf = function value of worstx(.)
%    xnstd(.) = standard deviation of parameters in the population
%    gnrng = normalized geometri%mean of parameter ranges
%    lcs(.) = indices locating position of s(.,.) in x(.,.)
%    bound(.) = bound on ith variable being optimized
%    ngs1 = number of complexes in current population
%    ngs2 = number of complexes in last population
%    iseed1 = current random seed
%    criter(.) = vector containing the best criterion values of the last
%                10 shuffling loops

% global BESTX BESTF ICALL PX PF
% Initialize SCE parameters:
nopt=length(x0);
npg=2*nopt+1;
% npg=1;
nps=nopt+1;
nspl=npg;
mings=ngs;
npt=npg*ngs;

bound = bu-bl;

% Create an initial population to fill array x(npt,nopt):
rand('seed',iseed);
x=repmat(bl,[npt,1])+rand(npt,nopt).*repmat(bound,[npt,1]);
% for i=1:npt;
%     x(i,:)=bl+rand(1,nopt).*bound;
% end;

if iniflg==1; x(1,:)=x0; end;

icall=size(x,1);
%% evaulate the initialized solution 
% the x parameters are divided in to n groups where n is the number of func
% get several simulator object copies
[argGroup,numEach]=PartitionArguments(simObj,funcAct,x,nParal);
parallel.defaultClusterProfile('local');
% funcWM(argGroup{1});
cluster = parcluster();
job = createJob(cluster);
WrapperHandles=cell(1,nParal);
for i=1:nParal
    WrapperHandles{i}=funcWM;
end
job.createTask(WrapperHandles, numEach, argGroup,'CaptureDiary',true);
job.submit();
nTrial=DispMultiTaskProg(job,0);
job.wait();
results = job.fetchOutputs();
results=results';
results=results(:);
xf=cell2mat(results);
% fh=WrapperHandles{1};
% xf=fh(argGroup{1});
f0=xf(1);
% Sort the population in order of increasing function values;
[xf,idx]=sort(xf);
x=x(idx,:);

% Record the best and worst points;
bestx=x(1,:); bestf=xf(1);
worstx=x(npt,:); worstf=xf(npt);
BESTF=bestf; BESTX=bestx;

% Compute the standard deviation for each parameter
xnstd=std(x);
% Computes the normalized geometric range of the parameters
gnrng=exp(mean(log((max(x)-min(x))./bound)));
SCE_UA_Dislay(logFile,0,bestf,bestx,worstf,worstx);
% Check for convergency;
if nTrial >= maxn;
    disp('*** OPTIMIZATION SEARCH TERMINATED BECAUSE THE LIMIT');
    disp('ON THE MAXIMUM NUMBER OF TRIALS ');
    disp(maxn);
    disp('HAS BEEN EXCEEDED.  SEARCH WAS STOPPED AT TRIAL NUMBER:');
    disp(nTrial);
    disp('OF THE INITIAL LOOP!');
end;

if gnrng < peps;
    disp('THE POPULATION HAS CONVERGED TO A PRESPECIFIED SMALL PARAMETER SPACE');
end;

% Begin evolution loops:
nloop = 0;
criter=[];
criter_change=1e+5;
k1=1:npg;
K2=repmat((k1-1)*ngs,[ngs,1])+repmat((1:ngs)',[1,npg]);
while nTrial<maxn && gnrng>peps && criter_change>pcento
    nloop=nloop+1;
    % Loop on complexes (sub-populations);
    delete(job);
    job = createJob(cluster);
    simArr=cell(ngs,1);
    simArr{1}=simObj;
    for i=2:ngs
        simArr{i}=copy(simObj);
    end
    for igs = 1: ngs
        % Partition the population into complexes (sub-populations);
        k2=K2(igs,:);
        cx = x(k2,:);
        cf = xf(k2);
        % Evolve sub-population igs for nspl steps:
        argIn={nspl,npg,nps,bl,bu,cf,cx,funcWS,funcAct,simArr{igs}};
        job.createTask(@EvolveComplex, 2, argIn,'CaptureDiary',true);
        % End of Loop on Complex Evolution;
    end
    job.submit();
    nTrial=DispMultiTaskProg(job,nTrial);
    wait(job);
    results = job.fetchOutputs();
    for igs = 1: ngs
        k2=K2(igs,:);
        % Replace the complex back into the population;
        cx=results{igs,2};
        cf=results{igs,1};
        x(k2,:) = cx;
        xf(k2) = cf;
    end
    % Shuffled the complexes;
    [xf,idx] = sort(xf); x=x(idx,:);
    PX=x; PF=xf;
    
    % Record the best and worst points;
    bestx=x(1,:); bestf=xf(1);
    worstx=x(npt,:); worstf=xf(npt);
    BESTX=[BESTX;bestx]; BESTF=[BESTF;bestf];

    % Compute the standard deviation for each parameter
    xnstd=std(x);

    % Computes the normalized geometric range of the parameters
    gnrng=exp(mean(log((max(x)-min(x))./bound)));

    SCE_UA_Dislay(logFile,nloop,bestf,bestx,worstf,worstx);

    % Check for convergency
    if nTrial >= maxn
        disp('*** OPTIMIZATION SEARCH TERMINATED BECAUSE THE LIMIT');
        disp(['ON THE MAXIMUM NUMBER OF TRIALS ' num2str(maxn) ' HAS BEEN EXCEEDED!']);
    end

    if gnrng < peps
        disp('THE POPULATION HAS CONVERGED TO A PRESPECIFIED SMALL PARAMETER SPACE');
    else
        disp(strcat('gnrng=',num2str(gnrng)))
    end
    criter=[criter,bestf];
    if (nloop >= kstop)
        criter_change=abs(criter(nloop)-criter(nloop-kstop+1));
        criter_change=criter_change/mean(abs(criter(nloop-kstop+1:nloop)));
        if criter_change < pcento
            disp(['THE BEST POINT HAS IMPROVED IN LAST ' num2str(kstop) ' LOOPS BY ', ...
                  'LESS THAN THE THRESHOLD ' num2str(pcento)]);
            disp('CONVERGENCY HAS ACHIEVED BASED ON OBJECTIVE FUNCTION CRITERIA!!!')
        else
            disp(criter)
        end
    end 
    % End of the Outer Loops
end

disp(['SEARCH WAS STOPPED AT TRIAL NUMBER: ' num2str(nTrial)]);
disp(['NORMALIZED GEOMETRIC RANGE = ' num2str(gnrng)]);
disp(['THE BEST POINT HAS IMPROVED IN LAST ' num2str(kstop) ' LOOPS BY ', ...
       num2str(criter_change) '%']);

% END of Subroutine sceua
return;
