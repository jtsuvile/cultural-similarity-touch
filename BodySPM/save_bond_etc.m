function save_bond_etc(datadir, country)
%%
subsfiledir = datadir;

if(strcmp(country, 'jp'))
    files = {'background1.txt','background2.txt','background3.txt'};
    max_length = [4,1,1];
    % NB: because the shuffling happens differently than in write bodies,
    % the order presented here is different. End result is the same, though
    order_stim = [1:6 9:16 7:8 17:20];
elseif (strcmp(country,'uk'))
    files = {'peopledetails.txt'};
    max_length = [6];
    order_stim = 1:20;
end
%temp = datadir;
%owd1=temp;
cd(datadir);
%temp = [datadir, '/mat-files/'];
subjects=textread([subsfiledir 'subs.txt']);
k=size(subjects,1);
extras = zeros(k,20,6);
%%
for na=1:k;
    sub=sprintf('%s/%s',pwd,num2str(subjects(na)));
    counter = 1;
    for fi=1:length(files)
        fid = fopen([sub '/' files{fi}]);
        for z=1:max_length(fi);
            try
                tline = fgets(fid);
                spli = strsplit(tline,':');
                rowtext = strrep(spli{2}, '>10', '11');
                extras(na, :, counter) = str2num(rowtext);
                counter = counter+1;
            catch err
                disp(['subject ' sub ' has problems with file ' files{fi} ' row ' z]);
                disp(counter);
                break
            end
        end
    end
    fclose('all');
end
%%
% fclose('all');
extras(extras <0) = NaN;
% orig_extras = extras;
%%
if(strcmp(country, 'jp'))
    %fix coding of time, only for JAPAN
    [row_weeks, col_weeks] = find(extras(:,:,3)==2); % weeks
    week_indices = sub2ind(size(extras), row_weeks, col_weeks, repmat(2,[size(row_weeks),1])); % the 'day' values of 'week's
    [row_months, col_months] = find(extras(:,:,3)==3); % months
    month_indices = sub2ind(size(extras), row_months, col_months, repmat(2,[size(col_months),1])); % the 'day' values of 'month's
    [row_years, col_years] = find(extras(:,:,3)==4); %years
    year_indices = sub2ind(size(extras), row_years, col_years, repmat(2,[size(col_years),1])); % the 'day' values of 'year's
    extras(week_indices) = extras(week_indices)*7;
    extras(month_indices) = extras(month_indices)*30;
    extras(year_indices) = extras(year_indices)*365;
    % take out 'lapse scale' to harmonize bg info order
    extras(:,:,3) = [];
    % fix order of stimuli in jp dataset
    extras = extras(:,order_stim,:);
end
%%
cd(subsfiledir);
pleasantness = extras(:,:,5);
dlmwrite(fullfile(['./',country,'_touch_pleasantness.csv']),pleasantness,'delimiter',',','precision',1);
bonds = extras(:,:,4);
dlmwrite(fullfile(['./',country,'_emotional_bonds.csv']),bonds,'delimiter',',','precision',10);
sex = extras(:,:,3);
dlmwrite(fullfile(['./',country,'_toucher_sex.csv']),sex,'delimiter',',','precision',1);
cd([subsfiledir 'mat-files']);
save('bondetc.mat', 'extras','-v7.3');

end
%% for manual qc: check if date conversion worked
% only relevant for japanese data
% 
% week_indices_2 = sub2ind(size(extras), row_weeks, col_weeks, repmat(2,[size(row_weeks),1])); % the 'day' values of 'week's
% week_indices_3 = sub2ind(size(extras), row_weeks, col_weeks, repmat(3,[size(row_weeks),1])); % the 'day' values of 'week's
% 
% month_indices_2 = sub2ind(size(extras), row_months, col_months, repmat(2,[size(col_months),1]));
% month_indices_3 = sub2ind(size(extras), row_months, col_months, repmat(3,[size(col_months),1]));
% 
% year_indices_2 = sub2ind(size(extras), row_years, col_years, repmat(2,[size(col_years),1])); % the 'day' values of 'year's
% year_indices_3 = sub2ind(size(extras), row_years, col_years, repmat(3,[size(col_years),1])); % the 'day' values of 'year's
% 
% %%
% [orig_extras(week_indices_2) extras(week_indices_3) extras(week_indices_2)];
% [orig_extras(month_indices_2) extras(month_indices_3) extras(month_indices_2)];
% [orig_extras(year_indices_2) extras(year_indices_3) extras(year_indices_2)];
% 
% find(orig_extras(week_indices_2)==0)
% find(orig_extras(month_indices_2)==0)
% find(orig_extras(year_indices_2)==0)
% 
% %end