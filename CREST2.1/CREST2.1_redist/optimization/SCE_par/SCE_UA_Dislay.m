function SCE_UA_Dislay(logFile,nloop,bestf,bestx,worstf,worstx)
disp(['The Initial Loop: ',num2str(nloop)]);
disp(['BESTF  : ' num2str(bestf)]);
disp(['BESTX  : ' num2str(bestx)]);
disp(['WORSTF : ' num2str(worstf)]);
disp(['WORSTX : ' num2str(worstx)]);
disp(' ');

fid=fopen(logFile,'a+');
fprintf(fid,'The Initial Loop: %d \n',nloop);
fprintf(fid,'BESTF  : %8.6f \n', bestf);
fprintf(fid,'BESTX  :');
fprintf(fid,' %8.6f ', bestx);
fprintf(fid,'\n');
fprintf(fid,'WORSTF : %8.6f \n',worstf);
fprintf(fid,'WORSTX : ');
fprintf(fid,' %8.6f ',worstx);
fprintf(fid,'\n');
fclose(fid);
end