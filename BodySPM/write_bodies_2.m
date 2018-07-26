function [k] = write_bodies_2(root, bodyspm, country)
% write_bodies(experiment)
% writes raw body data into matrix format
% assumes list of good subjects (subs.txt) residing in the data folder
% input = words / faces / movie / story
% original function by Enrico Glerean
% edited by Juulia Suvilehto
%% Basic definitions for the experiment
addpath(bodyspm)
base=uint8(imread(sprintf('%sbase2.png',bodyspm)));
mask=uint8(imread(sprintf('%sbase3.png',bodyspm)));
mask=mask*.85;
base2=base(10:531,33:203,:);
%% NB: japanese data presents stimuli in wrong order, it is fixed here

if(strcmp(country,'jp'))
    order_stim = [1:6 15:16 7:14 17:21]; % reshuffle such that niece and nephew are between acquaintance and stranger
else
    order_stim = 1:20; % already good
end

%% Hey ho, let's go ...

subdir=root;
cd(subdir);
D = dir(subdir);
if(~exist(sprintf('%s/%s', pwd, 'mat-files'), 'dir'));
    mkdir(pwd, 'mat-files');
end
subjects=textread('all_subs.txt');
qc_fail=textread('qc_fail.txt');
culture_fail = textread('not_clear_culture.txt');
good_subs = textread('subs.txt');
k=size(subjects,1);

%% Loop through the subjects & emotion conditions
for ns=1:k;
    sub=sprintf('%s/%s',subdir,num2str(subjects(ns)));
    %%
    list=csvread([sub '/presentation.txt']);
    N=length(list);
    a=load_subj(sub,2);
    if(strcmp(country,'jp'))
        S=21;
    else
        S=20;
    end
    disp(['Processing subject ' num2str(subjects(ns)) ' which is number ' num2str(ns) ' out of ' num2str(k)]);
    resmat=zeros(522,171*2,S);
    %%
    for n=1:S;
        target = order_stim(n);
        if(n==1 && list(n)~=0);
            over=nan(size(base,1),size(base,2));
            over2=[over(10:531,33:203,:) over(10:531,696:866,:)];
            resmat(:,:,target)=over2;
        elseif(n~=1 && isempty(find(list==n-1)));
            over=nan(size(base,1),size(base,2));
            over2=[over(10:531,33:203,:) over(10:531,696:866,:)];
            resmat(:,:,target)=over2;
        else
            if (n==1)
                T = length(a(1).paint(:,2));
                over=zeros(size(base,1),size(base,2));
                for t=1:T
                    y=ceil(a(1).paint(t,3)+1);
                    x=ceil(a(1).paint(t,2)+1);
                    if(x<=0) x=1; end
                    if(y<=0) y=1; end
                    if(x>=900) x=900; end
                    if(y>=600) y=600; end
                    over(y,x)=over(y,x)+1;
                end
            else
                T=length(a(find(list==n-1)).paint(:,2));
                over=zeros(size(base,1),size(base,2));
                for t=1:T
                    y=ceil(a(find(list==n-1)).paint(t,3)+1);
                    x=ceil(a(find(list==n-1)).paint(t,2)+1);
                    if(x<=0) x=1; end
                    if(y<=0) y=1; end
                    if(x>=900) x=900; end
                    if(y>=600) y=600; end
                    over(y,x)=over(y,x)+1;
                end
            end
            h=fspecial('gaussian',[25 25],8.5);
            over=imfilter(over,h);
            over2=[over(10:531,33:203,:) over(10:531,696:866,:)];
            resmat(:,:,target)=over2;
        end
    end
    %%
    resmat_full = resmat;
    if(strcmp(country,'jp'))
        resmat = resmat(:,:,1:20);
    end
    subname=sprintf('%s',num2str(subjects(ns)));
    matname=fullfile(root, 'mat-files', sprintf('subject_%s.mat',subname));
    save (matname, 'resmat');
    %%
    if(~exist(sprintf('%s/%s', pwd, '/qc_figures'), 'dir'));
        mkdir(sprintf('%s/%s', pwd, '/qc_figures/qc_fail'));
        mkdir(sprintf('%s/%s', pwd, '/qc_figures/culture_fail'));
        mkdir(sprintf('%s/%s', pwd, '/qc_figures/good_subs'));
    end
    
    if(strcmp(country, 'jp'))
        first= 1;
        last = 21;
    else
        first = 1;
        last = 20;
    end
    close all;
    %%
    for i=first:last;
        if(strcmp(country,'uk'))
            subplot(2,10,i);
        elseif(strcmp(country, 'jp')&& i<11)
            subplot(2,12,i);
        elseif(strcmp(country, 'jp')&& i<21)
            subplot(2,12,i+2);
        elseif(strcmp(country, 'jp')&& i==21)
            subplot(2,12,[11 12 21 22]);
        end
        over2=resmat_full(:,:,i);
        fh=imagesc(over2);
        axis('off');
        colormap(jet);
        set(gcf,'Color',[1 1 1]);
        
        %mask=ones(size(over2))*.7; old
        set(fh,'AlphaData',[mask mask])
    end
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 20 8];
    if(ismember(str2num(subname),good_subs))
        loc =sprintf('%s/%s', pwd, '/qc_figures/good_subs/');
    elseif(ismember(str2num(subname),culture_fail))
        loc =sprintf('%s/%s', pwd, '/qc_figures/culture_fail/');
    elseif(ismember(str2num(subname),qc_fail))
        loc =sprintf('%s/%s', pwd, '/qc_figures/qc_fail/');
    else
        loc =sprintf('%s/%s', pwd, '/qc_figures/');
    end
    fname1=sprintf('%s%s',loc,subname);
    print(fname1, '-dpng')

    close all
    %%
end

