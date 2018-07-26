function countTI(dataloc, bodyspmdir)
%%
    load(strcat(dataloc,'/mat-files/raw_results.mat'));
    location=(strcat(dataloc, '/mat-files/'));
%%
    a = size(data);
    subjects = a(4);
    targets=20;
    sli = zeros(subjects,targets);
    maskdata = nan(size(data));
    %means = zeros(subjects,1);
    %devs = zeros(subjects,1);
%%
    front = double(imread(sprintf('%smask_front_new.png',bodyspmdir)));
    back = double(imread(sprintf('%smask_back_new.png',bodyspmdir)));
    mask=sign(0.85*[front back]);
    mask = mask*-1;
    mask = mask+1;
%%
    data(data(:,:,:,:)>0)=1;
    for i=1:subjects
        for j=1:targets
            temp = data(:,:,j,i);
            foo = temp.*mask; % only include elements within body outline
            maskdata(:,:,j,i) = foo;
            sli(i,j) = nansum(nansum(foo,2));
        end
        %means(i) = nanmean(sli(i,:),2);
        %devs(i) = nanstd(sli(i,:));
    end
%%
    %figure;
%     mean_dummy = nanmean(sli);
%     [B, IX] = sort(mean_dummy, 'descend');
    %bar(B);
    %set(gca,'XTickLabel',compare_labels(IX));
%%
    %order = IX;
    %cd(location);
    %save('area_sorted_new.mat', 'order','-v7.3');
    save([location 'area_new.mat'],'sli','-v7.3');
    csvwrite([dataloc 'area_new.csv'],sli);
end