function varargout=funcWrapper(varargin)
nGroup=length(varargin)-1;
varargout=cell(nGroup,1);
funcHandle=varargin{1};
for i=1:nGroup
    arg=varargin{i+1};
    varargout{i}=funcHandle([],arg);
end
end