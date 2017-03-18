function Install
curDir = pwd;
%% add the directory of GDAL dependencies to windows ENVI path
%% add the CREST folders to matlab's searching directories
addpath([curDir '\GDALOperations'], ...
        [curDir '\optimization\'], ...
        [curDir '\optimization\SCE_par'],...
        [curDir '\CREST2.1_app']);
savepath
end