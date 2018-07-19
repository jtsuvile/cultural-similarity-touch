clear all;
close all;
trim = [1 3 4 5 6 7 8 9 10 11 12 13 14 17 18];
addpath('../BodySPM/cbrewer/');
bodyspmdir=('/Users/jtsuvile/Documents/projects/Touch/data/BodySPM/');

filedir = '/Volumes/SCRsocbrain/japan_soctouch/data/';
places = {'bondetc.mat'};

mask=double(imread(sprintf('%sbase4.png',bodyspmdir)));
mask=sign(0.85*[mask mask]);
mask(mask == 1) = -1;
big = 89129;
interest = 5; %5 == bond (4 in UK data), 2==lapse
women = [2, 4, 6, 8, 10, 12, 14];
men = women+1;
partner = 1;
%%
load(strcat(filedir, 'jp/mat-files/area_new.mat'));
load(strcat(filedir, 'jp/mat-files/bondetc.mat'));
load(strcat(filedir, 'jp/mat-files/social_network.mat'));
jp_sex = csvread(strcat(filedir, 'jp/JP_subinfo_for_matlab.csv'),1,1,[1,1,size(socnetwork,1),1]);
%%
filter = (socnetwork==0);
sli(filter) = NaN;
female = find(jp_sex(:,1));
male = find(~jp_sex(:,1));
%%
foo{1} = nanmean(sli(female,trim),1);
foo{1} = foo{1}/big;
foo{2} = nanmean(sli(male,trim),1);
foo{2} = foo{2}/big;

extras(extras==-1)=NaN;
bar{1} = nanmean(extras(female,trim,interest),1);
bar{2} = nanmean(extras(male,trim,interest),1);

foo{6} = nanmean(sli(:,trim),1);
foo{6} = foo{6}/big;
bar{6} = nanmean(extras(:,trim,4),1);
%%
clear sli;
clear socnetwork;
clear extras;
clear female;
clear male;
%% Add british data

load(strcat(filedir, 'en/mat-files/area_new.mat'));
load(strcat(filedir, 'en/mat-files/bondetc.mat'));
load(strcat(filedir, 'en/mat-files/social_network.mat'));
en_sex = csvread(strcat(filedir, 'en/EN_subinfo_for_matlab.csv'),1,1,[1,1,size(socnetwork,1),1]);

filter = (socnetwork==0);
sli(filter) = NaN;
female = find(en_sex(:,1));
male = find(~en_sex(:,1));
%%

foo{3} = nanmean(sli(female,trim),1);
foo{3} = foo{3}/big;
foo{4} = nanmean(sli(male,trim),1);
foo{4} = foo{4}/big;
extras(extras==-1)=NaN;
bar{3} = nanmean(extras(female,trim,4),1);
bar{4} = nanmean(extras(male,trim,4),1);

foo{5} = nanmean(sli(:,trim),1);
foo{5} = foo{5}/big;
bar{5} = nanmean(extras(:,trim,4),1);
clear sli;
clear extras;
clear socnetwork;
clear female;
clear male;
%%
group = [1 2 2 3 3 4 4 4 4 5 5 6 6 6 6];
col1_large = flipud(cbrewer('seq','Reds',9));
col1 = col1_large(3:8,:);
col2_large = flipud(cbrewer('seq','Greens',9));
col2 = col2_large(3:8,:);
col3_large = flipud(cbrewer('seq','Blues',9));
col3 = col3_large(3:8,:);
col4_large = flipud(cbrewer('seq','Purples',9));
col4 = col4_large(3:8,:);
col5_large = flipud(cbrewer('seq','Oranges',9));
col5 = col5_large(3:8,:);

%% Scatter by country and toucher sex
close all;
msize = 80;
ax = [0 10 0 0.7];
figure(1);
ha = tight_subplot(1,2,[0.04 0.05], [0.2,0.1], [0.2, 0.1]);

axes(ha(1))
scatter(bar{5}((women)), foo{5}((women)), msize, col1(2,:),'filled','MarkerEdgeColor',col1(2,:),'MarkerFaceAlpha',.8); 
hold on;
scatter(bar{5}((men)), foo{5}((men)), msize, col3(2,:),'filled','MarkerEdgeColor',col3(2,:),'MarkerFaceAlpha',.8); 
ls1 = lsline;
scatter(bar{5}((partner)), foo{5}((partner)), msize, col4(2,:),'filled','MarkerEdgeColor',col4(2,:),'MarkerFaceAlpha',.8); 
axis(ax);
set(ls1(2),'color',col1(2,:),'LineWidth',2);
set(ls1(1),'color',col3(2,:),'LineWidth',2);
tit4  = title('United Kingdom', 'VerticalAlignment', 'top');
axis square;
set(gca,'XTick', 0:1:10, 'TickDir', 'out', 'YTick',0:0.1:0.6,'FontSize', 16);

ylabel(sprintf('Touchability Index'), 'horizontalAlignment','center', 'rotation', 90,'FontSize', 16)

axes(ha(2))
scatter(bar{6}((women)), foo{6}((women)), msize, col1(2,:),'filled','MarkerEdgeColor',col1(2,:),'MarkerFaceAlpha',.8); 
hold on;
scatter(bar{6}((men)), foo{6}((men)), msize, col3(2,:),'filled','MarkerEdgeColor',col3(2,:),'MarkerFaceAlpha',.8); 
ls2 = lsline;
scatter(bar{6}((partner)), foo{6}((partner)), msize, col4(2,:),'filled','MarkerEdgeColor',col4(2,:),'MarkerFaceAlpha',.8);  
axis(ax);
set(ls2(2),'color',col1(2,:),'LineWidth',2);%,'XData',[0 10]);
set(ls2(1),'color',col3(2,:),'LineWidth',2);%,'XData',[0 10]);
tit4  = title('Japan', 'VerticalAlignment',  'top');
axis square;
set(gca,'XTick', 0:1:10,  'TickDir', 'out', 'YTick',0:0.1:0.6,'YTickLabel',[],'FontSize', 16);

xlabel(sprintf('Strength of Emotional Bond'), 'horizontalAlignment','center','verticalAlignment','top', 'FontSize', 16)

xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') - [6 0 0])
set(gcf,'color','w');
%%
orient landscape
print('/Users/jtsuvile/Documents/projects/jap-touch/visualizations/trellis_gender_wo_sub_sex','-dpdf', '-r0')
%% Another visualisation, with responses by male and female subjects presented separately
% this figure is not included in the manuscript
close all;
msize = 80;
ax = [0 10 0 0.7];
figure(1);
ha = tight_subplot(2,2,[0.04 -0.16], [0.2,0.1], [0.2, 0.1]);

axes(ha(1))
scatter(bar{1}((women)), foo{1}((women)), msize, col1(2,:),'filled','MarkerEdgeColor',col1(2,:),'MarkerFaceAlpha',.8); 
hold on;
scatter(bar{1}((men)), foo{1}((men)), msize, col3(2,:),'filled','MarkerEdgeColor',col3(2,:),'MarkerFaceAlpha',.8); 
ls1 = lsline;
scatter(bar{1}((partner)), foo{1}((partner)), msize, col4(2,:),'filled','MarkerEdgeColor',col4(2,:),'MarkerFaceAlpha',.8); 
axis(ax);
set(ls1(2),'color',col1(2,:),'LineWidth',2);
set(ls1(1),'color',col3(2,:),'LineWidth',2);
tit4  = title('JP female', 'VerticalAlignment', 'bottom');
axis square;
set(gca,'XTick', 0:1:10, 'XTickLabel',[], 'TickDir', 'out', 'YTick',0:0.1:0.6,'FontSize', 16);
set(gca,'XTick', 0:1:10,  'TickDir', 'out', 'YTick',0:0.1:0.6);
ylabel(sprintf('Touchability Index'), 'horizontalAlignment','center', 'rotation', 90,'FontSize', 16)

ylabh = get(gca,'YLabel');
set(ylabh,'Position',get(ylabh,'Position') - [0 0.4 0])

axes(ha(3))
%
%close all;
scatter(bar{2}((women)), foo{2}((women)), msize, col1(2,:),'filled','MarkerEdgeColor',col1(2,:),'MarkerFaceAlpha',.8); 
hold on;
scatter(bar{2}((men)), foo{2}((men)), msize, col3(2,:),'filled','MarkerEdgeColor',col3(2,:),'MarkerFaceAlpha',.8); 
ls2 = lsline;
scatter(bar{2}((partner)), foo{2}((partner)), msize, col4(2,:),'filled','MarkerEdgeColor',col4(2,:),'MarkerFaceAlpha',.8);  
axis(ax);
set(ls2(2),'color',col1(2,:),'LineWidth',2);%,'XData',[0 10]);
set(ls2(1),'color',col3(2,:),'LineWidth',2);%,'XData',[0 10]);
tit4  = title('JP male', 'VerticalAlignment',  'top');
axis square;
set(gca,'XTick', 0:1:10,  'TickDir', 'out', 'YTick',0:0.1:0.6,'FontSize', 16);
set(gca,'XTick', 0:1:10,  'TickDir', 'out', 'YTick',0:0.1:0.6);
%

axes(ha(2))
scatter(bar{3}((women)), foo{3}((women)), msize, col1(2,:),'filled','MarkerEdgeColor',col1(2,:),'MarkerFaceAlpha',.8); 
hold on;
scatter(bar{3}((men)), foo{3}((men)), msize, col3(2,:),'filled','MarkerEdgeColor',col3(2,:),'MarkerFaceAlpha',.8); 
ls3 = lsline;
scatter(bar{3}((partner)), foo{3}((partner)), msize, col4(2,:),'filled','MarkerEdgeColor',col4(2,:),'MarkerFaceAlpha',.8); 
axis(ax);
set(ls3(2),'color',col1(2,:),'LineWidth',2);
set(ls3(1),'color',col3(2,:),'LineWidth',2);
tit4  = title('UK female', 'VerticalAlignment', 'bottom');
axis square;

set(gca,'XTick', 0:1:10,  'XTickLabel',[], 'TickDir', 'out', 'YTick',0:0.1:0.6, 'YTickLabel', [], 'FontSize', 16);
set(gca,'XTick', 0:1:10,  'TickDir', 'out', 'YTick',0:0.1:0.6);

axes(ha(4))
scatter(bar{4}((women)), foo{4}((women)), msize, col1(2,:),'filled','MarkerEdgeColor',col1(2,:),'MarkerFaceAlpha',.8); 
hold on;
scatter(bar{4}((men)), foo{4}((men)), msize, col3(2,:),'filled','MarkerEdgeColor',col3(2,:),'MarkerFaceAlpha',.8); 
ls4 = lsline(gca);
scatter(bar{4}((partner)), foo{4}((partner)), msize, col4(2,:),'filled','MarkerEdgeColor',col4(2,:),'MarkerFaceAlpha',.8); 
axis(ax);

title('UK male', 'VerticalAlignment',  'top', 'FontSize', 18);
axis square;
set(ls4(2),'color',col1(2,:),'LineWidth',2);%,'XData',[0 10]);
set(ls4(1),'color',col3(2,:),'LineWidth',2);%,'XData',[0 10]);
set(gca,'XTick', 0:1:10,  'TickDir', 'out', 'YTick',0:0.1:0.6, 'YTickLabel', [], 'FontSize', 16);
set(gca,'XTick', 1:1:10,  'TickDir', 'out', 'YTick', 0:0.1:0.6);
xlabel(sprintf('Strength of Emotional Bond'), 'horizontalAlignment','center','verticalAlignment','top', 'FontSize', 16)

xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') - [6 0 0])
% 
compare_labels = {'partner' 'mom' 'dad' 'sister' 'brother' ...
     'aunt' 'uncle' 'f cousin' 'm cousin' ...
     'f friend' 'm friend' 'f contact' 'm contact' ...
      'f stranger' 'm stranger'};
set(gcf,'color','w');
%% save
orient landscape
print('/Users/jtsuvile/Documents/projects/jap-touch/visualizations/trellis_gender_comparison_w_reg_lines','-dpdf', '-r0')