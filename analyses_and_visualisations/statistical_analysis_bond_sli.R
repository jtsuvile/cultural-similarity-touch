library(ggplot2)
require(gridExtra)
require(grid)  
library(reshape)
library(QuantPsyc)
library(relaimpo)
library(psych)
source('../bodySPM/multiplot.R')

dataroot <- '/Users/jtsuvile/Documents/projects/jap-touch/data/'
trim = c(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18) # removes children who mess up the set!
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

total_uk <- readRDS(paste0(dataroot, 'uk','/total_uk.Rdata'))
total_jp <- readRDS(paste0(dataroot, 'jp','/total_jp.Rdata'))

# combine
total_both <- rbind(total_uk, total_jp)
total_both$country <- factor(total_both$country)

## VISUALISE THE AVERAGED DATA
jp_averages <- aggregate(total_jp[, c(5,7,8)], list(total_jp$person), mean)
uk_averages <- aggregate(total_uk[, c(5,7,8)], list(total_uk$person), mean)
jp_averages$country <- 'jp'
uk_averages$country <- 'uk'
both_avg <- rbind(uk_averages, jp_averages)
both_avg$country <- factor(both_avg$country)

lm_jp_avg <- lm(touchability_proportion~pleasantness+bond, data=jp_averages)
#summary(lm_jp_avg)
lm_uk_avg <- lm(touchability_proportion~pleasantness+bond, data=uk_averages)
#summary(lm_uk_avg)

lm_both_avg <- lm(scale(touchability_proportion)~scale(bond)+scale(pleasantness)+country, data=both_avg)
#lm_both_avg <- lm(touchability_proportion~bond*pleasantness*country, data=both_avg)

#summary(lm_both_avg)
#lm.beta(lm_both_avg)

relimp_avg <- calc.relimp(lm_both_avg, rela=FALSE)
#relimp_avg$lmg

textsize = 4
dotsize = 3
dotalpha = 0.5
both_avg$country_name <- 'UK'
both_avg$country_name[both_avg$country=='jp'] <- 'Japan'

p1 <- ggplot(data=both_avg, aes(x=bond, y=touchability_proportion, group=country, color=country)) +
  geom_point(size=dotsize, alpha=dotalpha, stroke = 0) +
  geom_smooth(method=lm, alpha=.2) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(0,0.7), breaks=seq(0,1,0.1))+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=16),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab('Touchability Index')

p2 <- ggplot(data=both_avg, aes(x=pleasantness, y=touchability_proportion, group=country_name, color=country_name)) +
  geom_point(size=dotsize, alpha=dotalpha,stroke = 0) +
  geom_smooth(method=lm, alpha=.2) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(0,0.7), breaks=seq(0,1,0.1))+
  scale_colour_discrete("Country") +
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position=c(.3, -1),
        #legend.position=c(-1, -0.6),
        legend.direction = 'horizontal',
        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=16),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  xlab('Pleasantness')+
  ylab('Touchability Index')

p3 <- ggplot(data=both_avg, aes(x=bond, y=pleasantness, group=country, color=country)) +
  geom_point(size=dotsize, alpha=dotalpha, stroke = 0) +
  geom_smooth(method=lm, alpha=.2) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(breaks=1:10, limits=c(1,10))+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position='none',
        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=16),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab('Pleasantness')


p_text <- ggplot(data=both_avg, aes(x=bond, y=pleasantness, group=country, color=country)) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(breaks=1:10, limits=c(1,10)) +
  geom_text(x=1,y=9, label='averaged data\nvariance in TI explained by', color='black',size=textsize,hjust=0) +
  geom_text(x=1,y=7, label=paste('bond:', round(relimp_avg$lmg['scale(bond)']*100,2),'%\npleasantness:', round(relimp_avg$lmg['scale(pleasantness)']*100,2),'%\nculture:', round(relimp_avg$lmg['country']*100,2),
                                 '%\naltogether:', round(relimp_avg$R2*100,2), '%'), 
            color='black',hjust=0) +
  theme_bw()+
  theme(line = element_blank(),
        axis.line = element_blank(),
        rect = element_blank(),
        title = element_blank(),
        axis.text = element_blank(),
        aspect.ratio = 1,
        legend.position="none")

pdf('/Users/jtsuvile/Documents/projects/jap-touch/visualizations/TI_bond_pleasantness.pdf')
multiplot(p1, p3, p2, p_text, cols=2)
dev.off()

## partial correlations for paper (averaged data)
correlations <- corr.test(both_avg[,c('bond','pleasantness','touchability_proportion')])
part_bond <- partial.r(data=correlations$r,c(1,3), c(2), method='spearman')
corr.p(part_bond, n=correlations$n)
part_pleas <- partial.r(data=correlations$r,c(2,3), c(1), method='spearman')
corr.p(part_pleas, n=correlations$n)

# average R squared
mean(c(summary(lm_uk_avg)$adj.r.squared,summary(lm_jp_avg)$adj.r.squared))

## VISUALISE UN-AVERAGED DATA (supplementary materials)
total_both$country <- factor(total_both$country, levels = c('jp','uk'), labels=c('Japan','UK'))
lm_both_3 <- lm(scale(touchability_proportion)~scale(pleasantness)+scale(bond)+country, data=total_both)
#summary(lm_both_3)

relimp_full <- calc.relimp(lm_both_3, rela=FALSE)
relimp_full$lmg

textsize = 4
dotsize = 3
dotalpha = 0.15

pf_1 <- ggplot(data=total_both, aes(x=bond, y=touchability_proportion, group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=dotalpha, width=0.25) +
  geom_smooth(method=lm, alpha=.2) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(0,0.7), breaks=seq(0,1,0.1))+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=16),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab('Touchability Index')

pf_2 <- ggplot(data=total_both, aes(x=pleasantness, y=touchability_proportion, group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=dotalpha, width=0.25) +
  geom_smooth(method=lm, alpha=.2) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(0,0.7), breaks=seq(0,1,0.1))+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position=c(.85, -.4),        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=16),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  xlab('Pleasantness')+
  ylab('Touchability Index')

pf_3 <- ggplot(data=total_both, aes(x=bond, y=pleasantness, group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=dotalpha, width=0.25) +
  geom_smooth(method=lm, alpha=.2) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(breaks=1:10, limits=c(1,10))+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(-0.25, "cm"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=16),
        axis.text.x = element_text(margin = margin(0.5, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.5, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab('Pleasantness')


pf_text <- ggplot(data=both_avg, aes(x=bond, y=pleasantness, group=country, color=country)) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(breaks=1:10, limits=c(1,10)) +
  geom_text(x=1,y=5, label='un-averaged data\nvariance in TI explained by', color='black',size=textsize,hjust=0) +
  geom_text(x=1,y=3, label=paste('bond:', round(relimp_full$lmg['scale(bond)']*100,2),'%\npleasantness:', round(relimp_full$lmg['scale(pleasantness)']*100,2),'%\nculture:', round(relimp_full$lmg['country']*100,2),
                                 '%\naltogether:', round(relimp_full$R2*100,2), '%'), 
            color='black',hjust=0) +
  theme_bw()+
  theme(line = element_blank(),
        axis.line = element_blank(),
        rect = element_blank(),
        title = element_blank(),
        axis.text = element_blank(),
        aspect.ratio = 1,
        legend.position="none")

pdf('/Users/jtsuvile/Documents/projects/jap-touch/visualizations/TI_bond_pleasantness_full_data.pdf')
multiplot(pf_1, pf_3, pf_2, pf_text, cols=2)
dev.off()

## Some additional statistical analyses
lm_jp <- lm(touchability~pleasantness+bond, data=total_jp)
#summary(lm_jp)
lm_uk <- lm(touchability~pleasantness+bond, data=total_uk)
#summary(lm_uk)

# average R squared
mean(c(summary(lm_uk)$adj.r.squared,summary(lm_jp)$adj.r.squared))

corr.test(total_jp[,c('touchability','bond','pleasantness')], method='spearman')
corr.test(total_uk[,c('touchability','bond','pleasantness')], method='spearman')

lm_both <- lm(touchability~bond*country, data=total_both)
lm_both_2 <- lm(scale(touchability)~scale(bond)+country+scale(pleasantness), data=total_both)
lm_both_4 <- lm(scale(touchability_proportion)~scale(bond)+scale(pleasantness)+country+country:scale(pleasantness)+scale(pleasantness):scale(bond), data=total_both)

summary(lm_both)
summary(lm_both_2)

calc.relimp(lm_both_4, rela=FALSE)
calc.relimp(lm_both_2, rela=FALSE)

correlations <- corr.test(total_both[,c('bond','pleasantness','touchability_proportion')])
par_bond <- partial.r(data=correlations$r,c(1,3), c(2), method='spearman')
par_pleas <- partial.r(data=correlations$r,c(2,3), c(1), method='spearman')
corr.p(par_bond, n=correlations$n)
corr.p(par_pleas, n=correlations$n)

# see average gender r2
lm_jp_f <- lm(touchability~bond+pleasantness, data=total_jp[total_jp$subsex=='female',])
lm_jp_m <- lm(touchability~bond+pleasantness, data=total_jp[total_jp$subsex=='male',])
lm_uk_f <- lm(touchability~bond+pleasantness, data=total_uk[total_uk$subsex=='female',])
lm_uk_m <- lm(touchability~bond+pleasantness, data=total_uk[total_uk$subsex=='male',])
r2s <- c(summary(lm_jp_f)$adj.r.squared,
         summary(lm_jp_m)$adj.r.squared,
         summary(lm_uk_f)$adj.r.squared,
         summary(lm_uk_m)$adj.r.squared)

print(paste0('mean adjusted R2 as presented in the paper: ', mean(r2s), ', range [', min(r2s), ', ', max(r2s), ']'))

calc.relimp(lm_jp_f, rela=FALSE)
calc.relimp(lm_jp_m, rela=FALSE)
calc.relimp(lm_uk_f, rela=FALSE)
calc.relimp(lm_uk_m, rela=FALSE)

## without partners
lm_both_no_partner <- lm(touchability~bond*country, data=total_both[total_both$person!='Partner',])
lm_both_no_partner_2 <- lm(scale(touchability)~scale(bond)*country, data=total_both[total_both$person!='Partner',])
summary(lm_both_no_partner_2)
lm.beta(lm_both)
calc.relimp(lm_both_no_partner_2)

sex_sex_both <- total_both[total_both$person!='Partner',]
sex_sex_both$toucher_sex <- 'female'
sex_sex_both$toucher_sex[sex_sex_both$person%in%c('Father',"Brother","Uncle","M_Cousin",
                                                  "M_Friend","M_Acq","M_Stranger")] <- 'male'

ano <- aov(touchability_proportion~toucher_sex*subsex, data=sex_sex_both)
summary(ano)

male_members <- c("Father","Brother","Uncle","M_Cousin","M_Friend","M_Acq","M_Stranger")
female_members <- c("Mother","Sister","Aunt","F_Cousin","F_Friend","F_Acq","F_Stranger")

corrs_en <- en_subjects[,c('subid','sex')]
rownames(corrs_en) <- corrs_en$subid
corrs_en$corr_male <- NA
corrs_en$corr_female <- NA

for(sub in unique(en_subjects$subid)){
  subset <- total_en[total_en$subid==sub,]
  if(sum(subset$person%in%male_members)>2){
    c_male <- cor.test(subset[subset$person%in%male_members,'bond'], subset[subset$person%in%male_members,'touchability_proportion'])
    corrs_en[corrs_en$subid==sub,'corr_male'] <- c_male$estimate
  }
  if(sum(subset$person%in%female_members)>2){
    c_female <- cor.test(subset[subset$person%in%female_members,'bond'], subset[subset$person%in%female_members,'touchability_proportion'])
    corrs_en[corrs_en$subid==sub, 'corr_female'] <- c_female$estimate
  }
}
