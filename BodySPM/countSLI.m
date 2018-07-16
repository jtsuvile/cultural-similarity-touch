function countSLI(dataloc, bodyspmdir)
    load(strcat(dataloc,'/mat-files/raw_results.mat'));
    location=(strcat(dataloc, '/mat-files/'));
    a = size(data);
    subjects = a(4);
    targets=20;
    sli = zeros(subjects,targets);
    maskdata = nan(size(data));
    means = zeros(subjects,1);
    devs = zeros(subjects,1);
%% read in mask for body
    front = double(imread(sprintf('%smask_front_new.png',bodyspmdir)));
    back = double(imread(sprintf('%smask_back_new.png',bodyspmdir)));
    mask=sign(0.85*[front back]);
    mask = mask*-1;
    mask = mask+1;
%% binarize data & count all coloured pixels within mask
    data(data(:,:,:,:)>0)=1;
    for i=1:subjects
        for j=1:targets
            temp = data(:,:,j,i);
            foo = temp.*mask; % only include elements within body outline
            maskdata(:,:,j,i) = foo;
            sli(i,j) = nansum(nansum(foo,2));
        end
        means(i) = nanmean(sli(i,:),2);
        devs(i) = nanstd(sli(i,:));
    end
%%  save 
    cd(location);
    save('area_new.mat','sli','-v7.3');
    % Save info also in non-matlab format
    dlmwrite(fullfile('area_new.csv'),sli,'delimiter',',','precision',10);
end