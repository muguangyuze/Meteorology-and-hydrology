function [argGroup,numInEachGroup]=PartitionArguments(simObj,ActHandle,argMat,nGroup)
% this function partition argument-sets into n groups for parellel calibration.
%% input
 % argMat: parameter-sets for calibration. For each model run, a single
    % parameter-set is in a row. the number of rows indicates the number of
    % testing sets
 % ActHandles: handle array of model run functions. The size of this array
 % indicates the parallel tasks(cores). Handles can be either the same or not.
%% output
 % argGroup: partitioned input arguments in a multi-level cell array. The first element
    % of each group is the function handle while the following are the arguments 
 % numInEachGroup: a double array of the number of model runs in each parallel task
simArr=cell(nGroup,1);
simArr{1}=simObj;
for i=2:nGroup
    simArr{i}=copy(simObj);
end
[nruns,nSingle]=size(argMat);
nCell=nSingle*ones(1,nruns);
argMat=reshape(argMat.',[1,nruns*nSingle]);
argCell = mat2cell(argMat, 1, nCell);
numEach=floor(nruns/nGroup);
reminder=mod(nruns,nGroup);
argGroup=cell(1,nGroup);
n0=0;
numInEachGroup=zeros(1,nGroup);
for i=1:nGroup
    if i<=reminder
        groupi=cell(1,numEach+3);
        groupi{1}=ActHandle;
        groupi{2}=simArr{i};
        groupi(3:end)=argCell(n0+1:n0+numEach+1);
        numInEachGroup(i)=numEach+1;
    else
        groupi=cell(1,numEach+2);
        groupi{1}=ActHandle;
        groupi{2}=simArr{i};
        groupi(3:end)=argCell(n0+1:n0+numEach);
        numInEachGroup(i)=numEach;
    end
    argGroup{i}=groupi;
    n0=n0+numInEachGroup(i);
end
end