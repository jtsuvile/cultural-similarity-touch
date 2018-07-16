% set BodySPM directory
bodyspmdir = './BodySPM/';
addpath(bodyspmdir)

%% Binarize coloring files
% In the raw coloring data, the colored pixels can have different values 
% depending on how long an area has been colored. The following takes the
% raw data matrix and saves it as full binarized raw data matrix as well as 
% toucher-specific raw data matrices (e.g. 'sister_binary_results.mat')
compare_labels = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
        'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
        'f_friend' 'm_friend' ...
        'niece' 'nephew' 'f_contact' 'm_contact'...
        'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};
% British data
dataloc_en = '/m/nbe/scratch/socbrain/japan_soctouch/data/en/';
if(exist(dataloc_en,'dir')~=7)
    mkdir(dataloc_en);
end
binarize_coloring(dataloc, compare_labels);
% Japanese data
dataloc_jp = '/m/nbe/scratch/socbrain/japan_soctouch/data/jp/';
if(exist(dataloc_jp,'dir')~=7)
    mkdir(dataloc_jp);
end
binarize_coloring(dataloc, compare_labels);
%% Calculate touchable body area (TI) by subject and target
% this code will create and save the following files in datadir/mat-files
% 'area_new.mat' with variable 'sli', which has number of coloured pixels
%       for each subject & each target person 
% 'area_new.csv' same as above, but csv instead of .mat (for R)
% (TI shown in manuscript = sli/size of mask)

% Japanese data
countSLI(dataloc_jp, bodyspmdir);
% British data
countSLI(dataloc_en, bodyspmdir);

%% Calculate proportion coloured per pixel (for visualisation)
dataloc = '/m/nbe/scratch/socbrain/japan_soctouch/data/';
cd(dataloc)
people_en = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'f_kid' 'm_kid'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};
for i=1:length(people_en)
    load([dataloc 'en/mat-files/' people_en{i} '_binary_results.mat']);
    
    n = size(partial_data,3) - sum(isnan(partial_data(1,1,:)));
    positives = nansum(partial_data,3);
    prop_acceptable = positives/n;
    
    save([dataloc  'en/mat-files/' people_en{i} '_proportion_acceptable.mat'], 'prop_acceptable','-v7.3');
end
people_jp = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'niece' 'nephew'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};

for i=1:length(people_jp)
    load([dataloc 'jp/mat-files/' people_jp{i} '_binary_results.mat']);
    
    n = size(partial_data,3) - sum(isnan(partial_data(1,1,:)));
    positives = nansum(partial_data,3);
    prop_acceptable = positives/n;
    
    save([dataloc 'jp/mat-files/' people_jp{i} '_proportion_acceptable.mat'], 'prop_acceptable','-v7.3');
end
%% collate proportion files

dataloc = '/m/nbe/scratch/socbrain/japan_soctouch/data/';
people_en = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'f_kid' 'm_kid' ...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};
all_prop_acceptable = zeros(522,342,20);

for i=1:20
    load([dataloc 'en/mat-files/' people_en{i} '_proportion_acceptable.mat']);
    all_prop_acceptable(:,:,i) = prop_acceptable;
end
 save([dataloc 'en/mat-files/all_proportion_acceptable.mat'], 'all_prop_acceptable','-v7.3');



dataloc = '/m/nbe/scratch/socbrain/japan_soctouch/data/';
people_jp = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'niece' 'nephew'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};
all_prop_acceptable = zeros(522,342,20);

for i=1:20
    load([dataloc 'jp/mat-files/' people_jp{i} '_proportion_acceptable.mat']);
    all_prop_acceptable(:,:,i) = prop_acceptable;
end
 save([dataloc 'jp/mat-files/all_proportion_acceptable.mat'], 'all_prop_acceptable','-v7.3');

