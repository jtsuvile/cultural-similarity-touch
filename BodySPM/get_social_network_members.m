function get_social_network_members(datadir,country)
    %clearvars %-except exps j;

    owd1 = datadir;
    temp = [datadir,'/mat-files/'];
    %%
    cd(owd1);
    subs=textread([datadir 'subs.txt']);
    k=size(subs,1);
    subjinfo = zeros(k,20);
    %%
    for ns=1:k;
        sub=sprintf('%s/%s',datadir,num2str(subs(ns)));
        if(strcmp(country, 'jp'))
            fid = fopen([sub '/select_people.txt']);
            order_stim = [1:6 9:16 7:8 17:20];
        else
            fid = fopen([sub '/peopledata.txt']);
            order_stim = 1:20;
        end
        try
            tline = fgets(fid);
            spli = strsplit(tline,',');
            for j=1:16
                subjinfo(ns, j) = str2num(spli{j});
            end
        catch err
            disp(ns);
            disp(sub);
            %disp(j);
            break
        end
        fclose('all');
    end
    % add strangers for everyone
    subjinfo(:,17:20) = 1;
    socnetwork=subjinfo(:,order_stim);
    %%
    cd([datadir 'mat-files']);
    save('social_network.mat', 'socnetwork','-v7.3');
    dlmwrite(fullfile(sprintf('%s/%s_socnetwork.csv',datadir, country)),socnetwork,'delimiter',',','precision',1);
end