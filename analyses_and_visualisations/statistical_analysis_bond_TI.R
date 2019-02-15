#rm(list = ls())
library(ggplot2)
require(gridExtra)
require(grid)  
library(reshape)
library(QuantPsyc)
library(relaimpo)
library(psych)
library(lme4)
library(car)
library(tidyr)
library(ordPens)
source('../bodySPM/multiplot.R')

dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
figlocation <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/figs/'
sinkfile <- "/Users/jtsuvile/Documents/projects/jap-touch/stat_analysis_bond_output.txt"

#sink(sinkfile)

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

total_uk <- readRDS(paste0(dataroot, 'uk','/total_uk.Rdata'))
total_jp <- readRDS(paste0(dataroot, 'jp','/total_jp.Rdata'))

# combine
total_both <- rbind(total_uk, total_jp)
total_both$country <- factor(total_both$country)

#get correlation between bond and pleasantness
corr_jp <- corr.test(total_jp[,c('bond','pleasantness')], method='spearman')
print(paste('correlation between touch pleasantness and bond in Japanese data:',corr_jp$r['pleasantness','bond'], 'p = ', corr_jp$p['pleasantness','bond']))
corr_uk <- corr.test(total_uk[,c('bond','pleasantness')], method='spearman')
print(paste('correlation between touch pleasantness and bond in British data:',corr_uk$r['pleasantness','bond'], 'p = ', corr_uk$p['pleasantness','bond']))

## VISUALISE THE AVERAGED DATA
jp_averages <- aggregate(total_jp[, c(5,7,8)], list(total_jp$person), mean)
jp_median <- aggregate(total_jp[, c(5,7)], list(total_jp$person), median)
colnames(jp_averages) <- c('person', 'bond_mean','pleasantness_mean','touchability_proportion')
colnames(jp_median) <- c('person', 'bond_median','pleasantness_median')

uk_averages <- aggregate(total_uk[, c(5,7,8)], list(total_uk$person), mean)
uk_median <- aggregate(total_uk[, c(5,7)], list(total_uk$person), median)
colnames(uk_averages) <- c('person', 'bond_mean','pleasantness_mean','touchability_proportion')
colnames(uk_median) <- c('person', 'bond_median','pleasantness_median')

jp_averages$country <- 'jp'
uk_averages$country <- 'uk'

jp_combined <- cbind(jp_averages, jp_median)
uk_combined <- cbind(uk_averages, uk_median)

both_avg <- rbind(uk_combined, jp_combined)
both_avg$country <- factor(both_avg$country)

#lm_jp_avg <- lm(touchability_proportion~pleasantness+bond, data=jp_averages)
#summary(lm_jp_avg)
#lm_uk_avg <- lm(touchability_proportion~pleasantness+bond, data=uk_averages)
#summary(lm_uk_avg)

#parametric, regular linear model with averaged data
lm_both_avg <- lm(scale(touchability_proportion)~scale(bond_mean)+scale(pleasantness_mean)+country, data=both_avg)
print('TI~ bond+pleasantness+country, averaged data: ')
summary(lm_both_avg)
print('betas for averaged data: ')
lm.beta(lm_both_avg)

relimp_avg <- calc.relimp(lm_both_avg, rela=FALSE)
print('relative importance (relimp) on averaged data: ')
relimp_avg$lmg

## VISUALISE AVERAGED DATA 
textsize = 4
dotsize = 3
dotalpha = 0.5
both_avg$country_name <- 'UK'
both_avg$country_name[both_avg$country=='jp'] <- 'Japan'

p1 <- ggplot(data=both_avg, aes(x=bond_mean, y=touchability_proportion, group=country, color=country)) +
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

p2 <- ggplot(data=both_avg, aes(x=pleasantness_mean, y=touchability_proportion, group=country_name, color=country_name)) +
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

p3 <- ggplot(data=both_avg, aes(x=bond_mean, y=pleasantness_mean, group=country, color=country)) +
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

pdf(paste0(figlocation,'/TI_bond_pleasantness.pdf'))
multiplot(p1, p3, p2, p_text, cols=2)
dev.off()

## partial correlations for paper (averaged data)
correlations <- corr.test(both_avg[,c('bond','pleasantness','touchability_proportion')])
part_bond <- partial.r(data=correlations$r,c(1,3), c(2), method='spearman')
no_pleasantness <- corr.p(part_bond, n=correlations$n)
print(paste("partial correlation on averaged data, TI~bond, pleasantness removed:", no_pleasantness$r[2,1]))
part_pleas <- partial.r(data=correlations$r,c(2,3), c(1), method='spearman')
no_bond <- corr.p(part_pleas, n=correlations$n)
print(paste("partial correlation on averaged data, TI~pleasantness, bond removed:", no_bond$r[2,1]))

# average R squared
# mean(c(summary(lm_uk_avg)$adj.r.squared,summary(lm_jp_avg)$adj.r.squared))

## VISUALISE UN-AVERAGED DATA (supplementary materials)
total_both$country <- factor(total_both$country, levels = c('jp','uk'), labels=c('Japan','UK'))
lm_both_3 <- lm(scale(touchability_proportion)~scale(pleasantness)+scale(bond)+country, data=total_both)
print('TI~ bond+pleasantness+country,full (unaveraged) data: ')
summary(lm_both_3)
print('betas for full (unaveraged) data: ')
lm.beta(lm_both_3)

relimp_full <- calc.relimp(lm_both_3, rela=FALSE)
print('relative importance (relimp) on full (unaveraged) data: ')
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

pdf(paste0(figlocation,'TI_bond_pleasantness_full_data.pdf'))
multiplot(pf_1, pf_3, pf_2, pf_text, cols=2)
dev.off()

## Some additional statistical analyses
lm_jp <- lm(touchability~pleasantness+bond, data=total_jp)
#summary(lm_jp)
lm_uk <- lm(touchability~pleasantness+bond, data=total_uk)
#summary(lm_uk)

# average R squared
#mean(c(summary(lm_uk)$adj.r.squared,summary(lm_jp)$adj.r.squared))

# parametric, regular linear model
lm_both_2 <- lm(scale(touchability)~scale(bond)+country+scale(pleasantness), data=total_both)
summary(lm_both_2)
calc.relimp(lm_both_2, rela=FALSE)

# mixed effects model with subject as random effect 
# only possible for un-averaged data
mixed_effects <- lmer(scale(touchability)~bond+country+pleasantness+(1|subid), data=total_both, REML=FALSE)
summary(mixed_effects)
Anova(mixed_effects)

correlations <- corr.test(total_both[,c('bond','pleasantness','touchability_proportion')])
par_bond <- partial.r(data=correlations$r,c(1,3), c(2), method='spearman')
par_pleas <- partial.r(data=correlations$r,c(2,3), c(1), method='spearman')
# partial correlation TI~bond, pleasantness removed
bond_corr_out <- corr.p(par_bond, n=correlations$n, alpha=0.05)
print(bond_corr_out, short=FALSE)
# partial correlation TI~pleasantness, bond removed
pleas_corr_out <- corr.p(par_pleas, n=correlations$n, alpha=0.05)
print(pleas_corr_out, short=FALSE)

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


#
# Using OrdPens to estimate impact of treating emotional bond as ordinal (not continuous) variable
# 
SmoothFit_avg <- with(both_avg,
                      ordSmooth(x=bond_median,y=touchability_proportion,u=cbind(as.numeric(country)),z=pleasantness_mean,
                                model = 'linear', intercept=TRUE, lambda=c(1000, 50, 10, 5, 0.1, 0.01, .001), nonpenu=1))
#SmoothFit_avg$coefficients
#SmoothFit_avg$fitted

# regression with unaveraged ordinal predictors
# 
SmoothFit <- with(total_both,
                  ordSmooth(x=bond,y=touchability_proportion,u=cbind(as.numeric(country)),z=pleasantness,
                            model = 'linear', intercept=TRUE, lambda=c(1000, 50, 10, 5, 0.1, 0.01, .001), nonpenu=1))
#SmoothFit$coefficients
#SmoothFit$fitted

#
# visualise OrdSmooth
# 
textsize = 4
dotsize = 3
dotalpha = 0.5
lambdas = c(2:4)
lam = 4
both_avg$country_name <- 'UK'
both_avg$country_name[both_avg$country=='jp'] <- 'Japan'
total_both$country_name <- 'UK'
total_both$country_name[total_both$country=='jp'] <- 'Japan'

long_SF_avg_lambda <- gather(data.frame(x=1:10,
                                        SmoothFit_avg$coefficients[2:11,lambdas]), lambdalevel, coefficient, X50:X5)

long_SF_lambda <- gather(data.frame(x=1:10,
                                    SmoothFit$coefficients[2:11,lambdas]), lambdalevel, coefficient, X50:X5)

os1 <- ggplot(data=both_avg, aes(x=bond_median, y=touchability_proportion, group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=dotalpha, stroke = 0) +
  geom_smooth(method=lm, alpha=.2, se=F) +
  annotate("text", x=1.2,y=0.7,label="A", colour="black", size=8)+
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(-0.02,0.7), breaks=seq(0,1,0.1))+
  theme_classic()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position=c(0.77,0),
        legend.justification = c(0, 0),
        legend.title=element_blank(),
        axis.ticks.length=unit(0.25, "cm"),
        plot.margin = unit(c(8,-20,-3,0), "pt"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=18),
        axis.text.x = element_text(margin = margin(0.1, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.3, unit = "cm"))) + 
  xlab(' ')+
  ylab('Touchability Index')

os2 <- ggplot(data=both_avg, aes(x=bond_median, y=SmoothFit_avg$fitted[,lam], group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=dotalpha, stroke = 0) +
  #geom_smooth(method=lm, alpha=.2,se=F) +
  annotate("text", x=1.2,y=0.7,label="B", colour="black", size=8)+
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(-0.02,0.7), breaks=seq(0,1,0.1))+
  theme_classic()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(0.25, "cm"),
        plot.margin = unit(c(8,0,-3,-10), "pt"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=18),
        axis.text.x = element_text(margin = margin(0.1, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.3, unit = "cm"))) + 
  xlab(' ')+
  ylab(' ')

os3 <- ggplot(data=long_SF_avg_lambda, aes(x=x,y=coefficient, color=lambdalevel)) +
  geom_point(size=dotsize, alpha=1, stroke = 0) +
  geom_line()+
  annotate("text", x=1.2,y=0.138,label="C", colour="black", size=8)+
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_color_manual(values=c('grey','darkgrey','black')) +
  theme_classic()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(0.25, "cm"),
        plot.margin = unit(c(8,0,-3,0), "pt"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=18),
        axis.text.x = element_text(margin = margin(0.1, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.3, unit = "cm"))) + 
  xlab(' ')+
  ylab('Coefficient')

os4 <- ggplot(data=total_both, aes(x=bond, y=touchability_proportion, group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=0.05, stroke = 0) +
  geom_smooth(method=lm, alpha=1,se=F) +
  annotate("text", x=1.2,y=0.7,label="D", colour="black", size=8)+
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(-0.02,0.7), breaks=seq(0,1,0.1))+
  theme_classic()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(0.25, "cm"),
        plot.margin = unit(c(-3,-20,8,0), "pt"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=18),
        axis.text.x = element_text(margin = margin(0.1, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.3, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab('Touchability Index')

os5 <- ggplot(data=total_both, aes(x=bond, y=SmoothFit$fitted[,lam], group=country, color=country)) +
  geom_jitter(size=dotsize, alpha=0.05, stroke = 0) +
  annotate("text", x=1.2,y=0.7,label="E", colour="black", size=8)+
  #geom_smooth(method=lm, alpha=1,se=F) +
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_y_continuous(limits=c(-0.02,0.7), breaks=seq(0,1,0.1))+
  theme_classic()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(0.25, "cm"),
        plot.margin = unit(c(-3,0,8,-10), "pt"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=18),
        axis.text.x = element_text(margin = margin(0.1, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.3, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab(' ')

os6 <- ggplot(data=long_SF_lambda, aes(x=x,y=coefficient, color=lambdalevel)) +
  geom_point(size=dotsize, stroke = 0) +
  geom_line()+
  annotate("text", x=1.2,y=0.192,label="F", colour="black", size=8)+
  scale_x_continuous(breaks=1:10, limits=c(1,10)) +
  scale_color_manual(values=c('grey','darkgrey','black')) +
  theme_classic()+
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        aspect.ratio = 1,
        legend.position="none",
        axis.ticks.length=unit(0.25, "cm"),
        plot.margin = unit(c(-3,0,8,0), "pt"),
        axis.ticks = element_line(size = .3),
        text = element_text(size=18),
        axis.text.x = element_text(margin = margin(0.1, unit = "cm")),
        axis.text.y = element_text(margin = margin(r=0.3, unit = "cm"))) + 
  xlab('Emotional Bond')+
  ylab('Coefficient')

pdf(paste0(figlocation,'/ordSmooth_lambda_bond_ggplot.pdf'), width=10, height=6)
multiplot(os1, os4, os2, os5, os3, os6, cols=3)
dev.off()


# calc.relimp(lm_jp_f, rela=FALSE)
# calc.relimp(lm_jp_m, rela=FALSE)
# calc.relimp(lm_uk_f, rela=FALSE)
# calc.relimp(lm_uk_m, rela=FALSE)
sink()
unlink(sinkfile)

# playground
require(MASS)
touchability_for_plots <- total_both$touchability_proportion+1

qqp(touchability_for_plots, "norm")
qqp(touchability_for_plots, "lnorm")
nbinom <- fitdistr(touchability_for_plots, "Negative Binomial")
qqp(touchability_for_plots, "nbinom", size = nbinom$estimate[[1]], mu = nbinom$estimate[[2]])
poisson <- fitdistr(touchability_for_plots, "Poisson")
qqp(touchability_for_plots, "pois", lambda=poisson$estimate[[1]])
gamma <- fitdistr(touchability_for_plots, "gamma")
qqp(touchability_for_plots, "gamma", shape = gamma$estimate[[1]], rate = gamma$estimate[[2]])

hist(total_both$touchability_proportion, main = "Bimodal", xlim = c(0, 1))

qqnorm(total_both$touchability_proportion-0.5)
qqline(total_both$touchability_proportion-0.5,  col = "blue", lwd = 2)

PQL <- glmmPQL(touchability_proportion ~ bond+country+pleasantness, ~1 | subid, family = quasibinomial(link = "logit"),
               data = total_both)
summary(PQL)
