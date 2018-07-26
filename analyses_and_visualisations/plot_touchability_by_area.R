rm(list = ls())
library(ggplot2)
#require(beanplot)
#library(colorspace)
library(reshape)
library(car)

bodyspmloc <- '/Users/jtsuvile/Documents/projects/cultural-universalism-touch/BodySPM/'
dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
figlocation <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/figs/'


people <- c('Partner', 'kid', 'Mother', 'Father', 'Sister', 'Brother', 
       'Aunt', 'Uncle', 'F_Cousin', 'M_Cousin',
       'F_Friend', 'M_Friend', 'F_Acq', 'M_Acq', 'm kid', 'f kid', 
       'F_Stranger', 'M_Stranger', 'rand f kid', 'rand m kid')
people_title <- c('partner','kid', 'mother', 'father', 'sister', 'brother',
                  'aunt', 'uncle', 'female\ncousin', 'male\ncousin' ,
                  'female\nfriend', 'male\nfriend', 'female\nacq.', 'male\nacq.', 'm_kid', 'f_kid',
                  'female\nstranger', 'male\nstranger', 'rand_f_kid', 'rand_m_kid')

trim <- c(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18)
interesting_people <- people[trim]  

pvals <- read.csv(paste0(dataroot,'/ROI_country_comparison_signif_diff_lm_fits.csv'),header=T,row.names = 1)

area_names <- read.table(paste0(bodyspmloc,'name_of_areas.txt'))
area_names <- t(area_names)
area_names_print <- area_names

jp_areas <- read.csv(paste0(dataroot, 'jp/average_prop_colored_by_area.csv'), header=F)
en_areas <- read.csv(paste0(dataroot, 'uk/average_prop_colored_by_area.csv'), header=F)

jp_bonds_all <- read.csv(paste0(dataroot, 'jp/jp_emotional_bonds.csv'), header=F, na.strings = 'NaN')
en_bonds_all <- read.csv(paste0(dataroot, 'uk/uk_emotional_bonds.csv'), header=F, na.strings = 'NaN')

jp_bonds <- jp_bonds_all[,trim]
en_bonds <- en_bonds_all[,trim]
en_bonds[en_bonds==-1] = NA

colnames(jp_areas) <- area_names_print
colnames(en_areas) <- area_names_print
rownames(jp_areas) <- interesting_people
rownames(en_areas) <- interesting_people
colnames(jp_bonds) <- interesting_people
colnames(en_bonds) <- interesting_people
en_areas$country <- 'uk'
jp_areas$country <- 'jp'
en_areas$person <- rownames(en_areas)
jp_areas$person <- rownames(jp_areas)
jp_areas$avg_bond <- colMeans(jp_bonds, na.rm=T)
en_areas$avg_bond <- colMeans(en_bonds, na.rm=T)

foo <- melt(jp_areas, id=c("person","country", "avg_bond"))
bar <- melt(en_areas, id=c("person","country", "avg_bond"))

bar_no_partner <- bar[-which(bar$person == 'Partner'),]
foo_no_partner <- foo[-which(foo$person == 'Partner'),]

foobar <- rbind(foo, bar)

foobar_no_partner <- foobar[-which(foobar$person == 'Partner'),]


linmods <- list()
summaries <- list()
intercepts <- data.frame(intercept=rep(0,13))
rownames(intercepts) <- area_names

for(area in area_names){
  linmod1 <- lm(value~avg_bond*country, data=foobar[foobar$variable == area,])
  linmod2 <- lm(value~avg_bond+country, data=foobar[foobar$variable == area,])
  am <- anova(linmod1, linmod2)
  if(am$`Pr(>F)`[2] < 0.003845){ # chance level 0.05 after p.adjust with n=13
    relevant_linmod <- linmod1
  } else {
    relevant_linmod <- linmod2
  }
  linmods[[length(linmods)+1]] <- relevant_linmod
  summaries[[length(summaries)+1]] <- summary(relevant_linmod)
  intercepts[area,] <- relevant_linmod$coefficients[1]
}

variable_order <- c(1,5,6,13,2,7,9,11,3,8,10,12,4)
#variable_order <- intercept_order$ix 

foobar$variable <- factor(foobar$variable, levels(foobar$variable)[variable_order])


#plot(colMeans(jp_bonds, na.rm=T), jp_areas$hand)

upper_lim_y = 1
lower_lim_y = -0.095
##
# THIS IS IT!
##
 
pdf(paste(figlocation, 'uk_jp_compare_ROI_facet_wrap_intercept_order_beta_colours', '.pdf', sep=''))
p=ggplot() +
  geom_hline(yintercept = 0, colour="gray75") +
  geom_point(data=foobar, aes(avg_bond, value, col=country), alpha=0.7) +
  geom_line(data=foobar, aes(avg_bond, value, col=country),alpha=0.5, stat='smooth', method=lm, se=FALSE, size=1) +
  facet_wrap(~variable, nrow=4, dir='v') +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_color_manual(breaks=unique(foobar$country), values= c('gray75','#F8766D','#00BFC4')) +#c('#00965E','#FF671F')) + #values=c('chartreuse3','deeppink1')
  scale_y_continuous(limits=c(lower_lim_y,upper_lim_y), breaks=seq(0,1,0.2))+
  theme_bw()+
  theme(panel.grid = element_blank(),
        strip.background = element_blank(),
        aspect.ratio = 1,
        #legend.position=c(1.1, .9)) + 
        legend.position=c(1, 0.1)) + 
  xlab('Emotional Bond')+
  ylab('Touchability Index per ROI')
 p2 = p +
  geom_text(data=data.frame(x=5, y=0.95, label='alpha',
                            variable=pvals$area),
            aes(x,y,label=label, colour=pvals$intercept_country[variable_order]), fontface=2, inherit.aes=FALSE, parse=TRUE)
#p2
p3 = p2 +
  geom_text(data=data.frame(x=6, y=0.95, label='beta',
                            variable=pvals$area),
            aes(x,y,label=label, colour=pvals$slope_country[variable_order]), fontface=2,  inherit.aes=FALSE, parse=TRUE)
p3
dev.off()
