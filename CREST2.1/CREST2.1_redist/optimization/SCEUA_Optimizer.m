classdef SCEUA_Optimizer<Optimizer
    properties(Access=private)      
        nGroup;        % number of complexes (sub-populations)
        iseed=-1;   % the random seed number (for repetetive testing purpose)
        iniflg=1;   % flag for initial parameter array (=1, included it in initial
        % population; otherwise, not included)
        maxn=2000;    % maximum number of function evaluations allowed during optimization
        kstop=10;      % maximum number of evolution loops before convergency
        percento=1e-4;   % the percentage change allowed in kstop loops before convergency
        peps=1e-3;     % predescribed distance of ending an evolution.
        STCD;
        nParal;
        simObj;
        fmt='%6d: %8.4f  %6d ';
    end
    properties(Constant)
        keywordsN={'NCalibStations','Name'};
        keywordsVar ={'RainFact'     ,'Ksat'    ,'WM',...
                      'B'            ,'IM'      ,'KE',...
                      'coeM'         ,'expM'    ,'coeR',...
                      'coeS'         ,'KS'      ,'KI'};
        keywordsSEA_UA={'iseed','ngs','maxn','kstop','pcento'}
    end
    methods
        function obj=SCEUA_Optimizer(calibPath,resPath,fH,so,nP)
            calibFile=strcat(calibPath,'calibrations.txt');
            logfile=SCEUA_Optimizer.GenLogFileName(resPath);
            commentSym='#';
            ns=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsN{1},commentSym);
            minVal=zeros(length(SCEUA_Optimizer.keywordsVar),ns);
            initVal=zeros(length(SCEUA_Optimizer.keywordsVar),ns);
            maxVal=zeros(length(SCEUA_Optimizer.keywordsVar),ns);
            stcd=zeros(ns,1);
            for s=1:ns
                stcd(s)=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsN{2},commentSym);
                for i=1:length(SCEUA_Optimizer.keywordsVar);
                    [minVal(i,s),initVal(i,s),maxVal(i,s)]=SCEUA_Optimizer.readVarInfo(calibFile,...
                        strcat(SCEUA_Optimizer.keywordsVar{i},'_',num2str(s)),commentSym);
                end
            end
            index=minVal==-1;
            minVal(index)=[];
            initVal(index)=[];
            maxVal(index)=[];
            minVal=minVal(:).';maxVal=maxVal(:).';initVal=initVal(:).';
            obj=obj@Optimizer(logfile,minVal,maxVal,fH,initVal);
            obj.simObj=so;
            obj.nParal=nP;
            obj.STCD=stcd;
            obj.iseed=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsSEA_UA{1},commentSym);
            obj.nGroup=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsSEA_UA{2},commentSym);
            obj.maxn=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsSEA_UA{3},commentSym);
            obj.kstop=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsSEA_UA{4},commentSym);
            obj.percento=SCEUA_Optimizer.readSingleVar(calibFile,SCEUA_Optimizer.keywordsSEA_UA{5},commentSym);
        end
        function optimize(obj,keyword)
            switch keyword
                case 'par'
                    obj.optimizeMultiTask();
                case 'seq'
                    obj.optimizeSeq();
            end
        end
        function optimizeMultiTask(obj)
            obj.LogHead();
            [obj.optX,obj.optF] = sceuaMultiTask(obj.x0,obj.lBound,obj.uBound,...
                    obj.maxn,obj.kstop,obj.percento,obj.peps,obj.nGroup,...
                    obj.iseed,obj.iniflg,...
                    @obj.funcWrapperMulti,@obj.functionWrapperSingle,obj.funcHandle,...
                     obj.simObj,obj.nParal,obj.logFile);
        end
        function optimizeSeq(obj)
            [obj.optX,obj.optF]=sceua_seq(obj.x0,obj.lBound,obj.uBound,...
                   obj.maxn,obj.kstop,obj.percento,obj.peps,obj.nGroup,...
                   obj.iseed,obj.iniflg,@obj.functionWrapperSeq,obj.funcHandle,obj.simObj);
        end
        function exportRes(obj,resPath)
            fileSCE_UA=strcat(resPath,'SCE_UA',datestr(now,'yyyymmdd_hh'),'.txt');
            dlmwrite(fileSCE_UA,obj.optX,'\t');
        end
        function LogHead(obj)
            fid=fopen(obj.logFile,'w');
            fprintf(fid,'NSCE  Elapsed_Time');
            for i=1:length(obj.x0);
                fprintf(fid,'  %s  ',obj.keywordsVar{i});
            end
            fprintf(fid,'\n');
            fclose(fid);
        end
        function LogToFile(obj,fTemp,tElapse,xTemp)
            fid=fopen(obj.logFile,'a+');
            fprintf(fid,obj.fmt,fTemp,tElapse);
            fprintf(fid,' %8.6f ',xTemp);
            fprintf(fid,'\n');
            fclose(fid);
        end
        function varargout=funcWrapperMulti(obj,varargin)
            %% make a series call within one task
            % first element in the varargin cell is the actual function
            % handle
            % the next ones are acutal input argument-sets for all calls
            % varargin=varargin{:};% uncomment for debug purpose
            ng=length(varargin)-2;
            varargout=cell(ng,1);
            fh=varargin{1};
            objSim=varargin{2};
            for i=1:ng
                arg=varargin{i+2};
                [NSCE,tElapse]=fh(objSim,arg,SCEUA_Optimizer.keywordsVar);
                varargout{i}=1-NSCE;
                disp(num2str(NSCE));
                obj.LogToFile(NSCE,tElapse,arg);
            end
        end
        function Fval=functionWrapperSingle(obj,varargin)
            %% make one call within one task
            fh=varargin{1};
            objSim=varargin{2};
            args=varargin{3};
            [NSCE,tElapse]=fh(objSim,args,SCEUA_Optimizer.keywordsVar);
            disp(num2str(NSCE));
            Fval=1-NSCE;
            obj.LogToFile(NSCE,tElapse,args);
        end
        function Fval=functionWrapperSeq(obj,varargin)
            fh=varargin{1};
            objSim=varargin{2};
            [NSCE,]=fh(objSim,varargin{3},SCEUA_Optimizer.keywordsVar);
            Fval=1-NSCE;
        end
    end
    methods (Static)
        function fileName=GenLogFileName(resPath)
            fileName=strcat(resPath,'log.txt');
        end
        function [minVal,initVal,maxVal]=readVarInfo(calibFile,keywordVar,commentSymbol)
            cFileID = fopen(calibFile);
            tline = fgetl(cFileID);
            minVal=-1;
            initVal=-1;
            maxVal=-1;
            while tline~=-1
                if strcmp(tline(1),commentSymbol)==1
                    tline = fgetl(cFileID);
                    continue;
                end
                strArr = regexp(tline,commentSymbol,'split');
                strContent=strArr{1};
                strContent=strtrim(strContent);
                if ~isempty(strfind(strContent, keywordVar))
                    strValue=regexp(strContent,'=','split');
                    strValue=regexp(strValue{2},'\t\t','split');
                    strValue{1}=regexprep(strValue{1},' ','');
                    strValue{2}=regexprep(strValue{2},'\t','');
                    strValue{2}=regexprep(strValue{2},' ','');
                    strValue{3}=regexprep(strValue{3},'\t','');
                    strValue{3}=regexprep(strValue{3},' ','');
                    minVal=str2double(strValue{1});
                    initVal=str2double(strValue{2});
                    maxVal=str2double(strValue{3});
                    break;
                end
                tline = fgetl(cFileID);
            end
            fclose(cFileID);
        end
        function value=readSingleVar(calibFile,keyword,commentSymbol)
            cFileID = fopen(calibFile);
            tline = fgetl(cFileID);
            while tline~=-1
                 if strcmp(tline(1),commentSymbol)==1
                     tline = fgetl(cFileID);
                     continue;
                 end
                 strArr = regexp(tline,commentSymbol,'split');
                 strContent=strArr{1};
                 strContent=strtrim(strContent);
                 if ~isempty(strfind(strContent, keyword))
                     
                     strValue=regexp(strContent,'=','split');
                     strValue{2}=regexprep(strValue{2},'\t','');
                     value=str2double(strValue{2});
                     break;
                 end
                 tline = fgetl(cFileID);
            end
        end
    end
end