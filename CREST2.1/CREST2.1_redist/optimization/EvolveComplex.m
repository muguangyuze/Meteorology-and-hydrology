function [cf,cx]=EvolveComplex(nspl,npg,nps,bl,bu,cf,cx,funcW,funcAct,simObj)
% This function Evolves a complex for one evolution.
% This function is originally part of the SCE_UA procedure and singled out
% for parallelization.
% Any computation in this function must be put in a single task while
% different calls of this function can be parallelized
%% input parameters
 % nspl = number of evolution steps for each complex before shuffling
 % npg  = number of members in a complex
 % nps  = number of members in a simplex
 % bl   = the lower bound of the parameters
 % bu   = the upper bound of the parameters
 % func = function handle of the model run.
    % Note that only a single and the actual handle is used here.
    % if different function handles are used for parallelization, make
    % multiple calls to this function with using a different func each time
 % cx(.,.) = coordinates of points in a complex
 % cf(.) = function values of cx(.,.)
 %% output parameters
  % cf and cx are the updated complex functino values and points after one
  % evolution.
  % icall the 
for loop=1:nspl            
    % Select simplex by sampling the complex according to a linear
    % probability distribution
    lcs=zeros(nps,1);
    lcs(1) = 1;
    for k3=2:nps
        for iter=1:1000
            lpos = 1 + floor(npg+0.5-sqrt((npg+0.5)^2 - npg*(npg+1)*rand));
            idx=find(lcs(1:k3-1)==lpos, 1); 
            if isempty(idx) 
                break; 
            end
        end
        lcs(k3) = lpos;
    end
    lcs=sort(lcs);

    % Construct the simplex:
%     s = zeros(nps,nopt);
    s=cx(lcs,:); sf = cf(lcs);

    [snew,fnew]=cceua(s,sf,bl,bu,funcW,funcAct,simObj);

    % Replace the worst point in Simplex with the new point:
    s(nps,:) = snew; sf(nps) = fnew;

    % Replace the simplex into the complex;
    cx(lcs,:) = s;
    cf(lcs) = sf;

    % Sort the complex;
    [cf,idx] = sort(cf); cx=cx(idx,:);
% End of Inner Loop for Competitive Evolution of Simplexes
end
end