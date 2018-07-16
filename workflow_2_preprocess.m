% set BodySPM directory
bodyspmdir = './BodySPM/';
addpath(bodyspmdir)
%% Binarize coloring files
% In the raw coloring data, the colored pixels can have different values 
% depending on how long an area has been colored. The following takes the
% raw data matrix and saves it as full binarized raw data matrix as well as 
% toucher-specific raw data matrices (e.g. 'sister_binary_results.mat')
people_en = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'f_kid' 'm_kid'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};

people_jp = {'partner' 'kid' 'mom' 'dad' 'sister' 'brother' ...
    'aunt' 'uncle' 'f_cousin' 'm_cousin' ...
    'f_friend' 'm_friend' ...
    'f_contact' 'm_contact' 'niece' 'nephew'...
    'f_stranger' 'm_stranger' 'rand_f_kid' 'rand_m_kid'};

% British data
dataloc_en = '/m/nbe/scratch/socbrain/japan_soctouch/data/en/';
if(exist(dataloc_en,'dir')~=7)
    mkdir(dataloc_en);
end
binarize_coloring(dataloc, people_en);
% Japanese data
dataloc_jp = '/m/nbe/scratch/socbrain/japan_soctouch/data/jp/';
if(exist(dataloc_jp,'dir')~=7)
    mkdir(dataloc_jp);
end
binarize_coloring(dataloc, people_jp);
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
% this code will create and save 
% '/mat-files/all_proportion_acceptable.mat' with variable 'all_prop_acceptable'
% which will have proportion colored pixels 
% British data
prop_colored(dataloc_en, people_en)
% Japanese data
prop_colored(dataloc_jp, people_jp)