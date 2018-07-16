function binarize_coloring(dataloc, compare_labels)
%% save full raw data as binary
load(strcat(dataloc, '/mat-files/raw_results.mat'));
data(data(:,:,:,:)>0)=1;
save(strcat(dataloc,'/mat-files/raw_binary_results.mat'), 'data', '-v7.3');
%% save binary data by person data so that matrices aren't too big to process later on
for i=1:20
    partial_data = squeeze(data(:,:,i,:));
    save([dataloc,'/mat-files/', compare_labels{i}, '_binary_results.mat'],'partial_data');
end
end