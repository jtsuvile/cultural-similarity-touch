% set BodySPM directory
bodyspmdir = '/m/nbe/scratch/socbrain/cultural_comparison_code_test/cultural-universalism-touch/BodySPM';
addpath(bodyspmdir)
dataloc = '/m/nbe/scratch/socbrain/cultural_comparison_code_test/data/';

%% Binarize coloring files
% In the raw coloring data, the colored pixels can have different values 
% depending on how long an area has been colored. The following takes the
% raw data matrix and saves it as full binarized raw data matrix as well as 
% toucher-specific raw data matrices (e.g. 'sister_binary_results.mat')
%dataloc = '/m/nbe/scratch/socbrain/cultural_comparison_code_test/data/';
dataloc_uk = [dataloc '/uk/'];
people_uk = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'f_kid' 'm_kid'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};

dataloc_jp = [dataloc '/jp/'];
people_jp = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'niece' 'nephew'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};

binarize_coloring(dataloc_uk, people_uk);
binarize_coloring(dataloc_jp, people_jp);
%% Calculate touchable body area (TI) by subject and target
% this code will create and save the following files in datadir/mat-files
% 'area_new.mat' with variable 'sli', which has number of coloured pixels
%       for each subject & each target person 
% 'area_new.csv' same as above, but csv instead of .mat (for R)
% (TI shown in manuscript = sli/size of mask)

% Japanese data
countTI(dataloc_jp, bodyspmdir);
% British data
countTI(dataloc_uk, bodyspmdir);
%% Calculate proportion coloured per pixel (for visualisation)
% this code will create and save 
% '/mat-files/all_proportion_acceptable.mat' with variable 'all_prop_acceptable'
% which will have proportion colored pixels 
% British data
prop_colored(dataloc_uk, people_uk)
% Japanese data
prop_colored(dataloc_jp, people_jp)
%% Save ROI-wise info
dataroot = '/m/nbe/scratch/socbrain/cultural_comparison_code_test/data/';
bodyspmdir='/m/nbe/scratch/socbrain/cultural_comparison_code_test/cultural-universalism-touch/BodySPM/';
save_touchability_by_area(dataroot, 'jp', bodyspmdir);
save_touchability_by_area(dataroot, 'uk', bodyspmdir);