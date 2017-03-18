function nTrial=DispMultiTaskProg(job,nTrial)
%% display itemizedly the information of a multiTask job
tasks=job.Tasks;
nTasks=length(tasks);
indices=zeros(nTasks,1);
while ~strcmp(job.State, 'finished')
    bEmpty=true;
    for i=1:nTasks
        if ~isempty(tasks(i).Diary)
            bEmpty=false;
        end
    end
    if bEmpty
       continue; 
    end
    for i=1:nTasks
        text=tasks(i).Diary;
        if ~(indices(i)==length(text))
            nTrial=nTrial+1;
            disp(strcat('Trial ',num2str(nTrial),': ',text(indices(i)+1:end)));
            indices(i)=length(text);
        end
    end
    pause(0.5);
end
end