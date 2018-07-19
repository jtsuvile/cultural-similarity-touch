    % T-maps
clear all;
close all;
full_labels = {'Partner' 'kid' 'Mother' 'Father' 'Sister' 'Brother' ...
    'Aunt' 'Uncle' 'Cousin' 'Cousin' ...
    'Friend' 'Friend' 'Acq.' 'Acq.' 'm kid' 'f kid' ...
     'Stranger' 'Stranger' 'rand f kid' 'rand m kid', 'check'};
order_trim = [1 3 4 5 6 7 8 9 10 11 12 13 14 17 18];

bodyspmdir=('/Users/jtsuvile/Documents/projects/Touch/data/BodySPM/');
front = double(imread(sprintf('%smask_front_new.png',bodyspmdir)));
back = double(imread(sprintf('%smask_back_new.png',bodyspmdir)));
front_outline = double(imread(sprintf('%sbase_11_front.png',bodyspmdir)));
back_outline = double(imread(sprintf('%sbase_11_back.png',bodyspmdir)));

mask = sign(0.85*[front back]);
mask(mask == 1) = -1;
outline = [front_outline back_outline];
outline(outline<50) = 0; 
%%
who = 1;

switch who
    case 1 % z score comparisons!
        load /Volumes/SCRsocbrain/japan_soctouch/data/prop_test_jp_minus_en_zscore_results.mat
        load /Volumes/SCRsocbrain/japan_soctouch/data/FDR_limits_for_zscores.mat
        tdata = zscores;
        order_trim = 1:15;
        cmap = flipud(cbrewer('div','RdBu',21));
        full_labels = {'Partner' 'Mother' 'Father' 'Sister' 'Brother' ...
        'Aunt' 'Uncle' 'Cousin' 'Cousin' ...
        'Friend' 'Friend' 'Acq.' 'Acq.'...
        'Stranger' 'Stranger'};
        maxval = 10; 
        minval = -10;
    case 2 % JP prop acceptable
        load /Volumes/SCRsocbrain/japan_soctouch/data/jp/mat-files/all_proportion_acceptable.mat
        cmap = colormap(hot);
        tdata = all_prop_acceptable;
        maxval = 1; 
        minval = 0;
        cutoff_prop = 0;
    case 3 % UK scaled
        load /Volumes/SCRsocbrain/japan_soctouch/data/en/mat-files/all_proportion_acceptable.mat
        cmap = colormap(hot);
        tdata = all_prop_acceptable;
        maxval = 1; %0.03;
        minval = 0;
        cutoff_prop = 0;
end
%% draw figure

% set figure properties
close all;
numcols = 15; 
rows = 1;
cols = 15;
fi = figure('Position', [100 100 800 650]);
half = 171;

%top row
a = axes('Position', [0.1300    0.5838    0.7750    0.3412], 'xticklabel',[], 'xtick',[],  'yticklabel',[], 'ytick',[], 'Visible','off');
tmppos = get(a,'position');
l1 = tmppos(1); 
b1 = tmppos(2); 
w1 = tmppos(3); 
h1 = tmppos(4); 
tmphorz = (w1/cols);
tmpvert = (h1/rows);

% draw
for s=1:length(order_trim)
    nth_row = (ceil(s/cols));
    nth_col = s-(nth_row-1)*cols;
    tmphorz_pos = l1+(nth_col-1)*tmphorz;
    tmpvert_pos = b1+(nth_row-1)*tmpvert;
    axes('position',[tmphorz_pos tmpvert_pos tmphorz tmpvert]);
    hold on;
    target = order_trim(s);
    temp=tdata(:,1:half,target);
    if(who==2||who==3)
        temp(abs(temp)<cutoff_prop)=0;
    else
        temp(abs(temp)<FDRres(target,2))=0;
    end
    temp1 = temp - outline(:,1:half);
    h = imshow(temp1,[minval maxval]);
    set(h, 'AlphaData', ~mask(:,1:half));
    colormap(cmap);
    v = axis;
    set(gcf,'Color',[1 1 1]);
    axis off;
end

%bottom row
hold on;
b2 = axes('Position', [0.1300    0.1900    0.7750    0.3412], 'xticklabel',[], 'xtick',[],  'yticklabel',[], 'ytick',[], 'Visible','off');
tmppos = get(b2,'position');
l = tmppos(1); 
b = tmppos(2); 
w = tmppos(3); 
he = tmppos(4); 
tmphorz = (w/cols);
tmpvert = (he/rows);
% draw
for s=1:length(order_trim)
    nth_row = (ceil(s/cols));
    nth_col = s-(nth_row-1)*cols;
    tmphorz_pos = l+(nth_col-1)*tmphorz;
    tmpvert_pos = b+0.135+(nth_row-1)*tmpvert;
    axes('position',[tmphorz_pos tmpvert_pos tmphorz tmpvert]);
    hold on;
    target = order_trim(s);
    temp=tdata(:,half:end,target);
    if(who==2||who==3)
        temp(abs(temp)<cutoff_prop)=0;
    else
        temp(abs(temp)<FDRres(target,2))=0;
    end
    temp1 = temp - outline(:,half:end);
    h = imshow(temp1,[minval maxval]);
    set(h, 'AlphaData', ~mask(:,half:end));
    colormap(cmap);
    tit = sprintf(full_labels{target});
    if mod(target,2)==0
        titcolor = 'b';
        titpos = [100 10 1];
    elseif target==1
        titcolor = 'k';
        titpos = [100 -50 1];
    else
        titcolor = 'r';
        titpos = [100 -50 1];
    end
    if(who==1)
        if mod(target,2)==0
            titcolor = 'r';
            titpos = [100 10 1];
        elseif target==1
            titcolor = 'k';
            titpos = [100 -50 1];
        else
            titcolor = 'b';
            titpos = [100 -50 1];
        end
    end
    T = title(tit, 'Color', titcolor);
    P = get(T,'position');
    set(T,'rotation',90,'position',[P(2)+55 P(1)-240 P(3)-25], 'HorizontalAlignment', 'center','VerticalAlignment', 'top', 'FontSize', 14, 'FontName','Arial')
    v = axis;
    set(gcf,'Color',[1 1 1]);
    axis off;
end

B=colorbar;
set(B, 'Position', [l+w+.01 0.450 .01 1.05*h1],'FontSize', 12, 'FontName','Arial')

allhandles = findall(fi,'type','axes');

text(-.025, b+2.2*he, 'Back',  'Parent', b2,'FontSize', 16, 'FontName','Arial', 'HorizontalAlignment', 'center','rotation',90)
text(-.025, 1.5*h1,'Front', 'Parent', a, 'FontSize', 16, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
if(who==1)
    text(l+w+.093, 0.825, '\itZ', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
    text(l+w+.093, 0.920, '  score', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
elseif (who==2||who==3)
    text(l+w+.097, 0.77, 'Proportion of subjects', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'left', 'rotation',90)
else
    text(l+w+.093, 0.825, '\itT', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
    text(l+w+.093, 0.920, '  score', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
end
%%
switch who
    case 1 % z score comparison
        print('Z score thresholds for drawn individuals: ');
        print(FDRres(order_trim));
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-tvalues-jp-minus-en' -png -m3.8
    case 2 % JP
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-JP_prop' -png -m3.8
    case 3 % UK
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-UK_prop' -png -m3.8
end
%%
