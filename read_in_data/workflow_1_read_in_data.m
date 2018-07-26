%% Loading in data, saving in nice format
bodyspm = '/Users/jtsuvile/Documents/projects/cultural-universalism-touch/BodySPM/';
datadir = '/Volumes/SCRsocbrain/cultural_comparison_code_test/data';
addpath(bodyspm)
%% Collect data
countries = {'jp','uk'};
for i=1:length(countries)
    country = countries{i};
    root = [datadir '/' country '/'];
    % NB: fixing order of stimuli in japanese samples happens already here
    % the code below saves [subnum].mat with subject-specific 3-d array, 
    % where each social network member is represented by an 522*322 pixel
    % array with colored pixels having values >0 (exact value depends on
    % how long the subject coloured that area). Social network members,
    % that the subject does not have (e.g. if the subject doesn't have any
    % siblings) are represented by same size NaN-array, so that all
    % subjects' mat-files are size 522*342*20
    write_bodies_2(root, bodyspm, country);
end

%% To gather non-colouring data, run get_sub_info.R in R
% this contains different variable types, so can be better cleaned in R
%%
check_bad_bond(datadir);
% note to self: replaced times >10 with NaN in bondetc matrix (don't have
% an exact number and matlab is very bad with factors)
%% combine data to large matrices
% NB: this creates an uncomfortably large array, best to run on cluster
datadir = '/m/nbe/scratch/socbrain/cultural_comparison_code_test/data';
addpath('/m/nbe/scratch/socbrain/cultural_comparison_code_test/cultural-universalism-touch/BodySPM');
countries = {'jp','uk'};
for(i=1:length(countries))
    country=countries{i};
    root = [datadir '/' country '/'];
    % saves raw_results.mat, which is a 4-d array with dimensions 522*342*21*Nsubs
    combine_bodies(root);    %
    % saves 'bondetc.mat', which contains a 3-d array with the following for
    % each subject, each toucher (N subs * 20 * 6)
    % 1. age
    % 2. time (in days) since last meeting this person
    % 3. sex (only recorded for partner and own child, the rest of the touchers
    % have sex by definition (e.g. aunt, brother)
    % 4. emotional bond with the person (1-10)
    % 5. how pleasant would you find it if this person touched you? (1-10)
    % 6. how pleasant do you think that this person would find it if you
    % touched them? (1-10)
    save_bond_etc(root, country);
    % collect info about existence of social network members 
    % 0 = this subject does not have this person in their social network
    % 1 = this subject has this person in their social network
    % for partner, additionally
    % 3 = married
    % 2 = cohabiting
    % 1 = has romantic partner but is not living together with them
    % 0 = single 
    get_social_network_members(root, country);
end