library(ggplot2)
require(gridExtra)
require(grid)  
library(reshape)
library(QuantPsyc)
library(relaimpo)
source('../bodySPM/summarySE.R')
source('../bodySPM/multiplot.R')

sinkfile <- "/Users/jtsuvile/Documents/projects/jap-touch/stat_gender_output.txt"
dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
figlocation <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/figs/'

trim = c(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18) 
people <- c('Partner', 'kid', 'Mother', 'Father', 'Sister', 'Brother', 
            'Aunt', 'Uncle', 'F_Cousin', 'M_Cousin',
            'F_Friend', 'M_Friend', 'F_Acq', 'M_Acq', 'm kid', 'f kid', 
            'F_Stranger', 'M_Stranger', 'rand f kid', 'rand m kid')#, 'check')
people_title <- c('partner','kid', 'mother', 'father', 'sister', 'brother',
                  'aunt', 'uncle', 'female\ncousin', 'male\ncousin' ,
                  'female\nfriend', 'male\nfriend', 'female\nacq.', 'male\nacq.', 'm_kid', 'f_kid',
                  'female\nstranger', 'male\nstranger', 'rand_f_kid', 'rand_m_kid')
interesting_people <- people[trim]  

whole_fig_size = 178524
inside_mask = 89129

total_uk <- readRDS(paste0(dataroot, 'uk/total_uk.Rdata'))
total_jp <- readRDS(paste0(dataroot, 'jp/total_jp.Rdata'))

total_both <- rbind(total_uk, total_jp)
total_both$country <- factor(total_both$country)

total_both$toucher_sex <- 'Partner'
total_both$toucher_sex[total_both$person %in% c( 'Mother',  'Sister', 
                                                 'Aunt',  'F_Cousin',
                                                 'F_Friend',  'F_Acq',
                                                 'F_Stranger' )] = 'Female'
total_both$toucher_sex[total_both$person %in% c( 'Father','Brother', 
                                                 'Uncle', 'M_Cousin',
                                                 'M_Friend', 'M_Acq', 
                                                 'M_Stranger')] = 'Male'
total_both$toucher_sex <- factor(total_both$toucher_sex, levels=c('Female','Male','Partner'))

no_partner <- total_both[total_both$person!='Partner',]
no_partner$relationship <- 'Stranger'
no_partner$relationship[no_partner$person=='Father'|no_partner$person=='Mother'] <- 'Parent'
no_partner$relationship[no_partner$person=='Brother'|no_partner$person=='Sister'] <- 'Sibling'
no_partner$relationship[no_partner$person=='Aunt'|no_partner$person=='Uncle'] <- 'Aunt/Uncle'
no_partner$relationship[no_partner$person=='F_Cousin'|no_partner$person=='M_Cousin'] <- 'Cousin'
no_partner$relationship[no_partner$person=='F_Friend'|no_partner$person=='M_Friend'] <- 'Friend'
no_partner$relationship[no_partner$person=='F_Acq'|no_partner$person=='M_Acq'] <- 'Acq.'
no_partner$relationship <- factor(no_partner$relationship, levels=c('Parent','Sibling','Aunt/Uncle','Cousin','Friend','Acq.','Stranger'))

no_partner_aggregate <- summarySE(no_partner, measurevar="touchability_proportion", groupvars=c("subsex", "person", "toucher_sex", 'relationship', 'country'), na.rm=TRUE)
no_partner_aggregate$country <- factor(no_partner_aggregate$country, levels = c('uk','jp'), labels= c('UK', 'Japan'))
no_partner_aggregate$subsex <- factor(no_partner_aggregate$subsex, levels = c('female','male'), labels= c('Female', 'Male'))

# Barchart
p5 <- ggplot(data=no_partner_aggregate, aes(x=relationship, 
                                            y=touchability_proportion, 
                                            fill = toucher_sex,
                                            group = toucher_sex))+
  geom_bar(stat="identity", alpha=0.8, size=0.5, position=position_dodge()) +
  geom_errorbar(aes(ymin=touchability_proportion-se, ymax=touchability_proportion+se),position=position_dodge(), width=0.8) +
  facet_grid(no_partner_aggregate$country~no_partner_aggregate$subsex) +
  ylab('Mean TI') + 
  scale_fill_brewer("Toucher\nsex",type='qual',palette = 'Set1', direction=1) +
  scale_x_discrete("Relationship") +
  guides(colour=guide_legend(title="Sex of toucher")) + 
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        #legend.position="none",
        text = element_text(size=16),
        axis.text.x = element_text(angle = 60, hjust = 1),
        strip.background = element_rect(colour="white", fill="white"),
        strip.text.y = element_text(face="bold", angle=0),
        strip.text.x = element_text(face="bold")) +
  ylim(0,0.5)

pdf(paste0(figlocation, '/gender_effect_barchart_facet_wrap.pdf'))
p5
dev.off()


small_agg <- summarySE(no_partner, measurevar="touchability_proportion", groupvars=c("country","subsex", "toucher_sex"), na.rm=TRUE)
small_agg$countrynames <- "United Kingdom"
small_agg$countrynames[small_agg$country=='jp'] <- 'Japan'
small_agg$countrynames <- factor(small_agg$countrynames, levels=c("United Kingdom","Japan"))

# interaction plot
p6 <- ggplot(data=no_partner_aggregate, aes(x=factor(toucher_sex), 
                                            y=touchability_proportion, 
                                            color = subsex,
                                            group = subsex))+
  geom_errorbar(data=small_agg, aes(ymin=touchability_proportion-ci, ymax=touchability_proportion+ci), width=0.1,alpha=0.9, color = "black") +
  geom_point(data=small_agg, aes(y=touchability_proportion, color=subsex), alpha=0.9, size=3) +
  geom_line(data=small_agg, aes(y=touchability_proportion, color=subsex),size=0.5, linetype=1) +
  facet_grid(~small_agg$countrynames) +
  ylab('Mean TI') + 
  xlab('Sex of Toucher') +
  scale_color_brewer("Sex of\nsubject",type='qual',palette = 'Set1', direction=1,
                     breaks=c("male", "female"),
                     labels=c("Male", "Female")) +
  scale_x_discrete(expand = c(0.1,0.1)) +
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1.3,
        #legend.position="none",
        text = element_text(size=16),
        strip.background = element_rect(colour="white", fill="white"),
        strip.text.x = element_text(size=16),
        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  ylim(0,0.3)

pdf(paste0(figlocation,'/gender_effect_interaction_plot.pdf'))
p6
dev.off()

## Statistical analyses
sinkwrite <- file(sinkfile, open = "wt")
sink(sinkwrite)

# ANOVA
lm_no_partner <- aov(touchability_proportion~subsex*toucher_sex*country, data=no_partner)
summary(lm_no_partner)
#TukeyHSD(lm_no_partner)

#main effect: country
print(paste('TI by country: jp mean =', mean(no_partner$touchability_proportion[no_partner$country=='jp']),
            'sd =', sd(no_partner$touchability_proportion[no_partner$country=='jp'])))
print(paste('TI by country: uk mean =', mean(no_partner$touchability_proportion[no_partner$country=='uk']),
            'sd =', sd(no_partner$touchability_proportion[no_partner$country=='uk'])))


# main effect: toucher sex
print(paste('TI by toucher sex: female toucher mean =', mean(no_partner$touchability_proportion[no_partner$toucher_sex=='Female']),
            'sd =',sd(no_partner$touchability_proportion[no_partner$toucher_sex=='Female'])))
print(paste('TI by toucher sex: male toucher mean =',mean(no_partner$touchability_proportion[no_partner$toucher_sex=='Male']),
            'sd =', sd(no_partner$touchability_proportion[no_partner$toucher_sex=='Male'])))
#t.test(no_partner$touchability_proportion[no_partner$toucher_sex=='Female'],no_partner$touchability_proportion[no_partner$toucher_sex=='Male'])

# main effect of subject sex was not significant

# interaction subsex:toucher sex
ss_ts <- summarySE(no_partner, measurevar="touchability_proportion", groupvars=c('subid',"toucher_sex", 'subsex'), na.rm=TRUE)
wide_ss_ts <- reshape(ss_ts, direction='wide', idvar = c('subid', 'subsex'), timevar= c('toucher_sex'), drop=c('se','sd','ci'))
female_diff <- wide_ss_ts[wide_ss_ts$subsex=='female','touchability_proportion.Female']-wide_ss_ts[wide_ss_ts$subsex=='female','touchability_proportion.Male']
male_diff <- wide_ss_ts[wide_ss_ts$subsex=='male','touchability_proportion.Female']-wide_ss_ts[wide_ss_ts$subsex=='male','touchability_proportion.Male']
print(paste('interaction subsex:toucher sex: mean TI difference in female subjects =',mean(female_diff),'sd =',sd(female_diff)))
print(paste('interaction subsex:toucher sex: mean TI difference in male subjects =',mean(male_diff),'sd =',sd(male_diff)))

print('t-test for interaction subsex:toucher sex:')
t.test(female_diff, male_diff)

# interaction subsex:country
ss_co <- summarySE(no_partner, measurevar="touchability_proportion", groupvars=c("country", 'subsex'), na.rm=TRUE)

print('interaction subsex:country:')
print(paste('Japanese male subjects mean TI =', ss_co$touchability_proportion[ss_co$subsex=='male'&ss_co$country=='jp'], 'sd =', ss_co$sd[ss_co$subsex=='male'&ss_co$country=='jp']))
print(paste('Japanese female subjects mean TI =', ss_co$touchability_proportion[ss_co$subsex=='female'&ss_co$country=='jp'], 'sd=', ss_co$sd[ss_co$subsex=='female'&ss_co$country=='jp']))
print(paste('British male subjects mean TI =', ss_co$touchability_proportion[ss_co$subsex=='male'&ss_co$country=='uk'], 'sd =', ss_co$sd[ss_co$subsex=='male'&ss_co$country=='uk']))
print(paste('British female subjects mean TI =', ss_co$touchability_proportion[ss_co$subsex=='female'&ss_co$country=='uk'], 'sd=', ss_co$sd[ss_co$subsex=='female'&ss_co$country=='uk']))

t_jpmjpf <- t.test(no_partner$touchability_proportion[no_partner$country=='jp'&no_partner$subsex=='male'], no_partner$touchability_proportion[no_partner$country=='jp'&no_partner$subsex=='female'])
t_jpmukm <- t.test(no_partner$touchability_proportion[no_partner$country=='jp'&no_partner$subsex=='male'], no_partner$touchability_proportion[no_partner$country=='uk'&no_partner$subsex=='male'])
t_jpmukf <- t.test(no_partner$touchability_proportion[no_partner$country=='jp'&no_partner$subsex=='male'], no_partner$touchability_proportion[no_partner$country=='uk'&no_partner$subsex=='female'])
print('Japanese male subjects have higher TI than the rest, with t-scores')
print(paste("jp male vs jp female, t-test score =", t_jpmjpf$statistic, "p = ", t_jpmjpf$p.value, '(df:', t_jpmjpf$parameter,')'))
print(paste("jp male vs uk male, t-test score =", t_jpmukm$statistic, "p = ", t_jpmukm$p.value, '(df:', t_jpmukm$parameter,')'))
print(paste("jp male vs uk female, t-test score =", t_jpmukf$statistic, "p = ", t_jpmukf$p.value, '(df:', t_jpmukf$parameter,')'))

# interaction toucher sex:country
ts_co <- summarySE(no_partner, measurevar="touchability_proportion", groupvars=c("country", 'toucher_sex'), na.rm=TRUE)
print('interaction toucher sex:country:')
print(paste('Japanese male touchers mean TI =', ts_co$touchability_proportion[ts_co$toucher_sex=='Male'&ss_co$country=='jp'], 'sd =', ts_co$sd[ts_co$toucher_sex=='Male'&ss_co$country=='jp']))
print(paste('Japanese female touchers mean TI =', ts_co$touchability_proportion[ts_co$toucher_sex=='Female'&ss_co$country=='jp'], 'sd =', ts_co$sd[ts_co$toucher_sex=='Female'&ss_co$country=='jp']))
print(paste('British male touchers mean TI =', ts_co$touchability_proportion[ts_co$toucher_sex=='Male'&ss_co$country=='uk'], 'sd =', ts_co$sd[ts_co$toucher_sex=='Male'&ss_co$country=='uk']))
print(paste('British female touchers mean TI =', ts_co$touchability_proportion[ts_co$toucher_sex=='Female'&ss_co$country=='uk'], 'sd =', ts_co$sd[ts_co$toucher_sex=='Female'&ss_co$country=='uk']))

t_ukfjpf <- t.test(no_partner$touchability_proportion[no_partner$country=='jp'&no_partner$toucher_sex=='Female'], no_partner$touchability_proportion[no_partner$country=='uk'&no_partner$toucher_sex=='Female'])
print(paste("uk female vs jp female touchers, t-test score =", t_ukfjpf$statistic, "p = ", t_ukfjpf$p.value, '(df:', t_ukfjpf$parameter,')'))

# t.test(no_partner$touchability_proportion[no_partner$country=='jp'&no_partner$toucher_sex=='Male'], no_partner$touchability_proportion[no_partner$country=='uk'&no_partner$toucher_sex=='Male']) # ns.

sink()
unlink(sinkwrite)

