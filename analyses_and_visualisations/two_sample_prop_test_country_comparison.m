%% Then, two-sample prop test (z score)
clear all;
close all;
dataloc = '/m/nbe/scratch/socbrain/cultural_comparison_code_test/data/';
addpath('/m/nbe/scratch/socbrain/cultural_comparison_code_test/cultural-universalism-touch/BodySPM')

countries = {'jp','uk'};
compare_labels = {'partner' 'mom' 'dad' 'sister' 'brother' ...
        'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
        'f_friend' 'm_friend' ...
        'f_contact' 'm_contact'...
        'f_stranger' 'm_stranger'};
FDRres = zeros(length(compare_labels), 2);
zscores = zeros(522,342,length(compare_labels));

%%
for j=1:length(compare_labels)
    load([dataloc, countries{1}, '/mat-files/', compare_labels{j}, '_binary_results.mat'])
    jpdata = partial_data;
    clearvars partial_data;
    load([dataloc, countries{2}, '/mat-files/', compare_labels{j}, '_binary_results.mat'])
    endata = partial_data;
    clearvars partial_data;
    %%
    Njp = sum(~isnan(jpdata(1,1,:)));
    Nen = sum(~isnan(endata(1,1,:)));
    empty_figure = zeros(size(endata,1),size(endata,2));

    for x=1:size(endata,1)
        for y=1:size(endata,2)
            % Formula and explanation e.g. at https://onlinecourses.science.psu.edu/stat414/node/268
            phatjp = nansum(jpdata(x,y,:),3) / Njp;
            phaten = nansum(endata(x,y,:),3) / Nen;
            phat = (nansum(jpdata(x,y,:),3) + nansum(endata(x,y,:),3)) / (Njp + Nen);
            Z_score = (phatjp - phaten)/sqrt(phat*(1-phat)*((1/Njp)+(1/Nen)));
            empty_figure(x,y) = Z_score;
        end
    end
    %%
    P        = 1-cdf('Normal',abs(empty_figure),0,1);
    plim = 0.025/(size(P,1)*size(P,2)); % bonferroni correction
    zlim = icdf('Normal',1-plim,0,1); % z score related bonferroni corrected p limit

    %%
    P        = 1-cdf('Normal',abs(empty_figure),0,1);
    [pID, pN]= FDR(P,0.05);
    % FDR will return NaN if there are no significant values. Let's change
    % the output for FDRres so that plotting is easier
    if(isnan(pN))
        zID = max(max(empty_figure))+1;
        zN = max(max(empty_figure))+1;
    else
        zID      = icdf('Normal',1-pID,0,1);     % Z threshold, indep or pos. correl.
        zN       = icdf('Normal',1-pN,0,1) ;     % Z threshold, no correl. assumptions, use this
    end
    FDRres(j,:)   = [zID,zN];
    zscores(:,:,j) = empty_figure;
end
%%
cd(dataloc);
save ('prop_test_jp_minus_en_zscore_results.mat', 'zscores'); 
disp('FDR limits');
save('FDR_limits_for_zscores.mat','FDRres');
disp('done');

