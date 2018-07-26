function [tID,tN] = combine_bodies(dataloc);
filt='sub*.mat';
owd1=dataloc;
cd (owd1);
subjects=textread('subs.txt');
k=size(subjects,1);
matfiles = strcat(dataloc, '/mat-files/');
cd(matfiles);
%%
files1=(dir(filt));
[r,c]=size(files1); % assess dim
r1=numel(files1);
%cd (owd1);
load(sprintf('%s',char(files1(2).name)'));
[v p s]=size(resmat);
data=zeros(v,p,s,k);
%%
for t=1:r1;
    disp(sprintf('Reading subject %u',t'));
    foo =strsplit(char(files1(t).name),'_');
    bar = strsplit(char(foo(2)),'.');
    if(ismember(str2num(char(bar(1))),subjects))
        cd (matfiles);
        load(sprintf('%s',char(files1(t).name)'));
        ind = find(subjects==str2num(char(bar(1))));
        data(:,:,:,ind)=resmat;
    end
end

disp(sprintf('Done with reading the data!'));
disp(sprintf(['Including ' num2str(size(data,4)) ' subjects out of ' num2str(r1)]));
disp(sprintf('Saving raw data matrix'));

save('raw_results.mat', 'data','-v7.3');
disp('done');
%save debug
