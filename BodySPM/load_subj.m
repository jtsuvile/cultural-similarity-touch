function data=load_subj(folder,option)
	disp(folder);
    list=csvread([folder '/presentation.txt']);
    N=length(list);
    if(option==0)
        disp('here')
        for n=0:N-1;
            file=[folder '/' num2str(n) '.csv'];
            fid = fopen(file);
            line=textscan(fid,'%s','CollectOutput',1,'Delimiter',';');
            data(:,n+1)=line{1};
        end
        data=data';
    end
    if(option==1)
        disp('option 1 not implemented')
    end
    if(option>=2)
        for n=1:N;
            file=[folder '/' num2str(list(n)) '.csv'];
            line=dlmread(file,',');
            delim=find(-1==line(:,1));
            data(n).mouse=line(1:delim(1)-1,:);
            data(n).paint=line((delim(1)+1):(delim(2)-1),:);
            data(n).mousedown=line((delim(2)+1):(delim(3)-1),:);
            data(n).mouseup=line((delim(3)+1):end,:);
        end
    end
