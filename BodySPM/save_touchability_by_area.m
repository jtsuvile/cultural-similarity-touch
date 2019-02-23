function save_touchability_by_area(dataroot, country, bodyspmdir)

trim = [1 3 4 5 6 7 8 9 10 11 12 13 14 17 18]; %removes children
%%
datafile = [dataroot country '/mat-files/raw_binary_results.mat'];
load(datafile);
networkfile = [dataroot country '/mat-files/social_network.mat'];
load(networkfile);
%%
front = double(imread(sprintf('%smask_front_new.png',bodyspmdir)));
front_areas_weird_proportions = imread(sprintf('%sfront_areas_new.png',bodyspmdir));
front_areas = front_areas_weird_proportions(:,:,1);
back_areas_weird_proportions = imread(sprintf('%sback_areas_new.png',bodyspmdir));
back_areas = back_areas_weird_proportions(:,:,1);
%%
hair_color = 26;
face_color = 179;
shoulder_back_color = 128;
shoulder_front_color = 77;
arm_color = 102;
hand_color = 204;
torso_front_color = 153;
torso_back_color = 51;
grotch_color = 128;
butt_color = 77;
leg_front_color = 51;
foot_color = 230;
%%
hair_indices_front = find(front_areas==hair_color);
hair_indices_back = find(back_areas==hair_color);
face_indices = find(front_areas==face_color);
arm_indices = find(front_areas==arm_color);
shoulder_indices_front = find(front_areas==shoulder_front_color);
shoulder_indices_back = find(back_areas==shoulder_back_color);
hand_indices = find(front_areas==hand_color);
torso_indices_front = find(front_areas==torso_front_color);
torso_indices_back = find(back_areas==torso_back_color);
grotch_indices = find(front_areas==grotch_color);
butt_indices = find(back_areas==butt_color);
leg_indices = find(front_areas==leg_front_color);
foot_indices = find(front_areas==foot_color);
%%
n_subjects = size(data,4);
res = NaN(length(trim),13,n_subjects);

for i=1:n_subjects
    for j=1:length(trim)
        if socnetwork(i, trim(j)) == 0
            res(j,:,i) = NaN;
        else
            temp_data_front = data(:,1:171,trim(j),i);
            temp_data_back = data(:,172:end,trim(j),i);
            res(j,1,i) = size(find(temp_data_front(hair_indices_front)),1) + size(find(temp_data_back(hair_indices_back)),1);
            res(j,2,i) = size(find(temp_data_front(face_indices)),1);
            res(j,3,i) = size(find(temp_data_front(shoulder_indices_front)),1);
            res(j,4,i) = size(find(temp_data_back(shoulder_indices_back)),1);
            res(j,5,i) = size(find(temp_data_front(arm_indices)),1) + size(find(temp_data_back(arm_indices)),1);
            res(j,6,i) = size(find(temp_data_front(hand_indices)),1) + size(find(temp_data_back(hand_indices)),1);
            res(j,7,i) = size(find(temp_data_front(torso_indices_front)),1);
            res(j,8,i) = size(find(temp_data_back(torso_indices_back)),1);
            res(j,9,i) = size(find(temp_data_front(grotch_indices)),1);
            res(j,10,i) = size(find(temp_data_back(butt_indices)),1);
            res(j,11,i) = size(find(temp_data_front(leg_indices)),1);
            res(j,12,i) = size(find(temp_data_back(leg_indices)),1);
            res(j,13,i) = size(find(temp_data_front(foot_indices)),1) + size(find(temp_data_back(foot_indices)),1);
        end
    end
end
%%
size_of_areas = [size(hair_indices_front,1)+size(hair_indices_back,1) size(face_indices,1) size(shoulder_indices_front,1) ...
    size(shoulder_indices_back,1) size(arm_indices,1)*2 size(hand_indices,1)*2 size(torso_indices_front,1) size(torso_indices_back,1) ...
    size(grotch_indices,1) size(butt_indices,1) size(leg_indices,1) size(leg_indices,1) size(foot_indices,1)*2];
sizes_of_areas = repmat(size_of_areas, [15 1]);
areas = {'hair','face','shoulder_front','shoulder_back','arm','hand','torso_front','torso_back','crotch','bottom','leg_front','leg_back','foot'};

%%
avg_res = nanmean(res,3);
prop_avg_res = avg_res./sizes_of_areas;
median_res = nanmedian(res,3);
prop_median_res = median_res./sizes_of_areas;
%% Save all
save([dataroot country '/mat-files/colored_pixels_by_subject_by_area'], 'res', 'areas', 'trim', 'size_of_areas');
csvwrite([dataroot country '/average_pixels_by_area.csv'], avg_res);
csvwrite([dataroot country '/average_prop_colored_by_area.csv'], prop_avg_res);
csvwrite([dataroot country '/median_pixels_by_area.csv'], median_res);
csvwrite([dataroot country '/median_prop_colored_by_area.csv'], prop_median_res);
%% write info on ROI sizes and names (in order)
csvwrite([bodyspmdir '/size_of_areas.csv'], size_of_areas);
fileID = fopen([bodyspmdir '/name_of_areas.txt'],'w');
formatSpec = '%s\n';
[nrows, ncols] = size(areas);
for row = 1:nrows
    fprintf(fileID,formatSpec,areas{row,:});
end
fclose(fileID);
%%
arealoc = [dataroot country '/areas/'];
if(~exist(arealoc,'dir'))
    mkdir(arealoc)
end

for k=1:length(areas)
    curr = squeeze(res(:,k,:))';
    curr_prop = curr/size_of_areas(k);
    csvwrite([arealoc areas{k} '_pixels_by_subject.csv'], curr);
    csvwrite([arealoc areas{k} '_prop_by_subject.csv'], curr_prop);
end
%%
disp('done');
end