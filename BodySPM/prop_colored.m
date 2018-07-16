function prop_colored(dataloc, people)
cd(dataloc)
for i=1:length(people)
    load([dataloc '/mat-files/' people{i} '_binary_results.mat']);
    n = size(partial_data,3) - sum(isnan(partial_data(1,1,:)));
    positives = nansum(partial_data,3);
    prop_acceptable = positives/n;
    save([dataloc  '/mat-files/' people{i} '_proportion_acceptable.mat'], 'prop_acceptable','-v7.3');
end
clearvars prop_acceptable i 

%% collate proportion files
all_prop_acceptable = zeros(522,342,20);

for i=1:20
    load([dataloc '/mat-files/' people{i} '_proportion_acceptable.mat']);
    all_prop_acceptable(:,:,i) = prop_acceptable;
end
 save([dataloc '/mat-files/all_proportion_acceptable.mat'], 'all_prop_acceptable','-v7.3');
end