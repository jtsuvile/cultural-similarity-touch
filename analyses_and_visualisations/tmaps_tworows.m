    % T-maps
clear all;
close all;
full_labels = {'Partner' 'kid' 'Mother' 'Father' 'Sister' 'Brother' ...
    'Aunt' 'Uncle' 'Cousin' 'Cousin' ...
    'Friend' 'Friend' 'Acq.' 'Acq.' 'm kid' 'f kid' ...
     'Stranger' 'Stranger' 'rand f kid' 'rand m kid', 'check'};
% full_labels = {'Puoliso' 'kid' '?iti' 'Is?' 'Sisko' 'Veli' ...
%     'T?ti' 'Set?\nEno' 'Serkku' 'Serkku' ...
%     'Yst?v?' 'Yst?v?' 'Tuttu' 'Tuttu' 'm kid' 'f kid' ...
%      'Vieras' 'Vieras' 'rand f kid' 'rand m kid', 'check'};
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
who = 3;

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
        %load /Volumes/SCRsocbrain/japan_soctouch/data/jp/mat-files/FDR_limits.mat
        cmap = colormap(hot);
        tdata = all_prop_acceptable;
        maxval = 1; 
        minval = 0;
    case 3 % UK scaled
        load /Volumes/SCRsocbrain/japan_soctouch/data/en/mat-files/all_proportion_acceptable.mat
        %load /Volumes/SCRsocbrain/japan_soctouch/data/en/mat-files/FDR_limits.mat
        cmap = colormap(hot);
        tdata = all_prop_acceptable;
        maxval = 1; %0.03;
        minval = 0;
end
%%
% load /Volumes/amor/scratch/socbrain/soctouch/word_data_all/t_sorted_all.mat
% largest_tval = max(max(max(tdata(:,:,trim))));
% tdata= tdata./largest_tval;
% %  if no thresholding!
% FDRres(:,:) = 0;
% %% if difference between countries
% for i=1:20
%     tmp = tdata(:,:,i);
%     tmp(tmp < FDRres(i,2)) = 0;
%     tdata(:,:,i) = tmp;
% end
% jpdata = tdata/largest_tval;
% tdata2 = jpdata(:,:,1:20) - endata;

%%
close all;
cutoff_prop = 0.5;
numcols = 15; %ceil(max(max(max(tdata))))-5;

rows = 1;
cols = 15;
% diff of tvalues 
% 


fi = figure('Position', [100 100 800 650]);
a = axes('Position', [0.1300    0.5838    0.7750    0.3412], 'xticklabel',[], 'xtick',[],  'yticklabel',[], 'ytick',[], 'Visible','off');
tmppos = get(a,'position');
%tmppos
l1 = tmppos(1); 
b1 = tmppos(2); 
w1 = tmppos(3); 
h1 = tmppos(4); 

%delete(a);
tmphorz = (w1/cols);
tmpvert = (h1/rows);

%cmap = colormap(jet(numcols)); 
%cmap = [0 0 0;cmap];
%cmap = flipud(cbrewer('div','RdBu',21));

half = 171;


for s=1:length(order_trim)
    nth_row = (ceil(s/cols));
    nth_col = s-(nth_row-1)*cols;
    tmphorz_pos = l1+(nth_col-1)*tmphorz;
    tmpvert_pos = b1+(nth_row-1)*tmpvert;
    axes('position',[tmphorz_pos tmpvert_pos tmphorz tmpvert]);
    hold on;
    target = order_trim(s);
    temp=tdata(:,1:half,target);
    if(who==8||who==9)
        temp(abs(temp)<cutoff_prop)=0;
        %temp = temp;
    else
        temp(abs(temp)<FDRres(target,2))=0;
    end
    temp1 = temp - outline(:,1:half);
    %h = imshow(temp1,[0 1]);
    h = imshow(temp1,[minval maxval]);
    set(h, 'AlphaData', ~mask(:,1:half));
    colormap(cmap);
    v = axis;
    set(gcf,'Color',[1 1 1]);
    axis off;
end

hold on;
b2 = axes('Position', [0.1300    0.1900    0.7750    0.3412], 'xticklabel',[], 'xtick',[],  'yticklabel',[], 'ytick',[], 'Visible','off');
tmppos = get(b2,'position');
%tmppos
l = tmppos(1); 
b = tmppos(2); 
w = tmppos(3); 
he = tmppos(4); 

%delete(a);
tmphorz = (w/cols);
tmpvert = (he/rows);

for s=1:length(order_trim)
    nth_row = (ceil(s/cols));
    nth_col = s-(nth_row-1)*cols;
    tmphorz_pos = l+(nth_col-1)*tmphorz;
    tmpvert_pos = b+0.135+(nth_row-1)*tmpvert;
    axes('position',[tmphorz_pos tmpvert_pos tmphorz tmpvert]);
    hold on;
    target = order_trim(s);
    temp=tdata(:,half:end,target);
    if(who==8||who==9)
        temp(abs(temp)<cutoff_prop)=0;
        %temp = temp;
    else
        temp(abs(temp)<FDRres(target,2))=0;
    end
    temp1 = temp - outline(:,half:end);
    %h = imshow(temp1,[0 1]);
    h = imshow(temp1,[minval maxval]);
    %h = imagesc(temp);
    set(h, 'AlphaData', ~mask(:,half:end));
    %colormap(map);
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
    if(who==7)
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
% if(who==8||who==9)
%     set(B,'YTickLabel',{'Taboo','Universally\newlineacceptable'}, ...
%                'YTick', 0:1, 'TickInterpreter','tex');
% end

%%
allhandles = findall(fi,'type','axes');

text(-.025, b+2.2*he, 'Back',  'Parent', b2,'FontSize', 16, 'FontName','Arial', 'HorizontalAlignment', 'center','rotation',90)
text(-.025, 1.5*h1,'Front', 'Parent', a, 'FontSize', 16, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
if(who==7)
    text(l+w+.093, 0.825, '\itZ', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
    text(l+w+.093, 0.920, '  score', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
elseif (who==8||who==9)
    text(l+w+.097, 0.77, 'Proportion of subjects', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'left', 'rotation',90)
else
    text(l+w+.093, 0.825, '\itT', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
    text(l+w+.093, 0.920, '  score', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
end


% text(-.025, b+2.2*he, 'Selk?puoli',  'Parent', b2,'FontSize', 16, 'FontName','Arial', 'HorizontalAlignment', 'center','rotation',90)
% text(-.025, 1.5*h1,'Etupuoli', 'Parent', a, 'FontSize', 16, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
% text(l+w+.093, 0.825, '\itT', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)
% text(l+w+.093, 0.920, ' -arvo', 'Parent', b2,'FontSize', 12, 'FontName','Arial','HorizontalAlignment', 'center', 'rotation',90)

%notouch = text(-.02, 0.02, sprintf('Taboo\nzone'), 'Parent', a, 'Color', 'k','FontSize', 12, 'FontName','Arial', 'HorizontalAlignment', 'center');

%notouch = text(-.02, 0.02, sprintf('Taboo\nzone'), 'Parent', a, 'Color', 'k','FontSize', 12, 'FontName','Arial', 'HorizontalAlignment', 'center');

%bigfi = imresize(fi,5);
%imshow(bigfi)
%set(fi ); 
%%
switch who
    case 1 % all
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-JP' -png -m3.8
    case 2 % UK
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-UK' -png -m3.8
    case 3 %girls
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-UK-male-scaled' -png -m3.8
    case 4 % boys
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-UK-female-scaled' -png -m3.8
    case 5 %girls
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-JP-male-scaled' -png -m3.8
    case 6 % boys
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-JP-female-scaled' -png -m3.8
    case 7 % z score comparison
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-tvalues-jp-minus-en' -png -m3.8
    case 8 % all
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-JP_prop' -png -m3.8
    case 9 % UK
        export_fig '/Users/jtsuvile/Documents/projects/jap-touch/visualizations/heatmaps-hot-UK_prop' -png -m3.8
end
%%
