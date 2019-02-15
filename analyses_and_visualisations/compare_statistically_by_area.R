rm(list = ls())
library(ggplot2)
library(reshape)
library(grid)
library(gridExtra)
library(relaimpo)

bodyspmloc <- '/Users/jtsuvile/Documents/projects/cultural-universalism-touch/BodySPM/'
dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
sink("/Users/jtsuvile/Documents/projects/jap-touch/ROI.txt")


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
area_names <- read.table(paste0(bodyspmloc,"name_of_areas.txt"))
area_names <- t(area_names)
area_names_print <- area_names

jp_bonds_all <- read.csv(paste0(dataroot, '/jp/jp_emotional_bonds.csv'), header=F, na.strings = 'NaN')
en_bonds_all <- read.csv(paste0(dataroot, '/uk/uk_emotional_bonds.csv'), header=F, na.strings = 'NaN')
filename1 <- paste0(dataroot,'/ROI_lm_r_squared.csv')
filename2 <-  paste0(dataroot, '/ROI_country_comparison_signif_diff_lm_fits.csv')
jp_bonds <- jp_bonds_all[,trim]
en_bonds <- en_bonds_all[,trim]
en_bonds[en_bonds==-1] = NA  
colnames(jp_bonds) <- interesting_people
colnames(en_bonds) <- interesting_people
en_bonds$country <- 'uk'
jp_bonds$country <- 'jp'

en_bonds$subid <- paste('en',as.character(seq(1,dim(en_bonds)[1])), sep='')
en_bonds$subid <- factor(en_bonds$subid)

jp_bonds$subid <- paste('jp',as.character(seq(1,dim(jp_bonds)[1])), sep='')
jp_bonds$subid <- factor(jp_bonds$subid)

diffs <- data.frame(matrix(ncol=3, nrow=length(area_names)))
colnames(diffs) <- c('p_slope','p_intercept_plus','p_intercept_times')
rownames(diffs) <- area_names
relimps <- data.frame(matrix(ncol=4, nrow=length(area_names)))
colnames(relimps) <- c('person', 'country','bond','R2')
rownames(relimps) <- area_names
lms <- list()
lms1 <- list()
lms2 <- list()
ams <- list()
subwise_results_jp <- data.frame(matrix(ncol=length(area_names), nrow=nrow(jp_bonds)))
colnames(subwise_results_jp) <- area_names
subwise_results_en <- data.frame(matrix(ncol=length(area_names), nrow=nrow(en_bonds)))
colnames(subwise_results_en) <- area_names

for(area in area_names){
  location=area;
  jp <- read.csv(paste0(dataroot, 'jp/areas/', location, '_prop_by_subject.csv'), header=F, na.strings='NaN')
  en <- read.csv(paste0(dataroot, 'uk/areas/', location, '_prop_by_subject.csv'), header=F, na.strings='NaN')
  colnames(jp) <- interesting_people
  colnames(en) <- interesting_people
  en$country <- 'uk'
  jp$country <- 'jp'
  en$location <- location
  jp$location <- location
  en$subid <- paste('en',as.character(seq(1,dim(en)[1])), sep='')
  en$subid <- factor(en$subid)
  jp$subid <- paste('jp',as.character(seq(1,dim(jp)[1])), sep='')
  jp$subid <- factor(jp$subid)
  
  jp_sli_long <- melt(jp)
  colnames(jp_sli_long) <- c('country','location', 'subid', 'person', 'sli')
  jp_bonds_long <- melt(jp_bonds)
  colnames(jp_bonds_long) <- c('country','subid', 'person', 'bond')
  
  en_sli_long <- melt(en)
  colnames(en_sli_long) <- c('country','location', 'subid', 'person', 'sli')
  en_bonds_long <- melt(en_bonds)
  colnames(en_bonds_long) <- c('country','subid', 'person', 'bond')
  
  jp_long <- merge(jp_bonds_long, jp_sli_long, by=c('subid','country','person'))
  en_long <- merge(en_bonds_long, en_sli_long, by=c('subid','country','person'))
  
  both <- rbind(en_long, jp_long)
  
  lm1 <- lm(sli~country+bond, data=both)
  lm2 <- lm(sli~country*bond, data=both)
  am <- anova(lm1,lm2)
  diffs[area, 'p_interaction'] <- am$`Pr(>F)`[2]
  
  lms2[[length(lms2)+1]] <- summary(lm2)
  diffs[area, 'p_intercept_times'] <- summary(lm2)$coefficients[[2,4]]
  diffs[area, 'p_slope'] <- summary(lm2)$coefficients[[4,4]]
  lms1[[length(lms1)+1]] <- summary(lm1)
  diffs[area, 'p_intercept_plus'] <- summary(lm1)$coefficients[[2,4]]

  ams[[length(ams)+1]] <- am
  
}

diffs$p_adj_slope <- p.adjust(diffs$p_interaction)
diffs$p_intercept <- diffs$p_intercept_plus
diffs$p_intercept[diffs$p_adj_slope < 0.05] <- diffs$p_intercept_times[diffs$p_adj_slope < 0.05]
diffs$p_adj_intercept <- p.adjust(diffs$p_intercept)

diffs$signif_intercept <- 'NO'
diffs$signif_intercept[diffs$p_adj_intercept < 0.05] <- 'YES'
diffs$intercept_country <- 'NO'
diffs$signif_slope <- 'NO'
diffs$signif_slope[diffs$p_adj_slope < 0.05] <- 'YES'
diffs$slope_country <- 'NO'
diffs$area <- rownames(diffs)
diffs$tval_slope <- NA
diffs$tval_intercept <- NA

for(reg in 1:length(area_names)){
  if(diffs[area_names[reg],'signif_slope'] == 'YES'){
    temp_summary <- lms2[[reg]]
    countryuk_slope <- temp_summary$coefficients['countryuk:bond','Estimate']
    diffs[area_names[reg],'tval_slope'] <- temp_summary$coefficients['countryuk:bond','t value']
    if(countryuk_slope>0){
      diffs[area_names[reg],'slope_country'] <- 'uk'
    } else {
      diffs[area_names[reg],'slope_country'] <- 'jp'
    }
    if(diffs[area_names[reg],'signif_intercept'] == 'YES'){
      countryuk <- temp_summary$coefficients['countryuk','Estimate']
      diffs[area_names[reg],'tval_intercept']<- temp_summary$coefficients['countryuk','t value']
      if(countryuk>0){
        diffs[area_names[reg],'intercept_country'] <- 'uk'
      } else {
        diffs[area_names[reg],'intercept_country'] <- 'jp'
      }
    }
  } else if(diffs[reg,'signif_intercept'] == 'YES'){
    temp_summary <- lms1[[reg]]
    countryuk_lm1 <- temp_summary$coefficients['countryuk','Estimate']
    diffs[area_names[reg],'tval_intercept']<- temp_summary$coefficients['countryuk','t value']
    if(countryuk_lm1>0){
      diffs[area_names[reg],'intercept_country'] <- 'uk'
    } else {
      diffs[area_names[reg],'intercept_country'] <- 'jp'
    }
  }
}

rsqs <- data.frame(matrix(ncol=2, nrow=length(area_names)))
colnames(rsqs) <- c('r_squared', 'adj_r_squared')
rownames(rsqs) <- area_names

effects_intercept <- data.frame(matrix(ncol=5, nrow=length(area_names)))
colnames(effects_intercept) <- c("estimate","stderr","tval","p_t","df")
rownames(effects_intercept) <- area_names

effects_slope <- data.frame(matrix(ncol=5, nrow=length(area_names)))
colnames(effects_slope) <- c("estimate","stderr","tval","p_t","df")
rownames(effects_slope) <- area_names

for(i in 1:length(area_names)){
  if(diffs$p_adj_slope[i]<0.05){
    use_summary = lms2[[i]]
  } else {
    use_summary = lms1[[i]]
  }
  if(diffs$p_adj_slope[i]<0.05){
    effects_slope[i,1:4] <- use_summary$coefficients['countryuk:bond',]
    effects_slope[i,5] <- use_summary$df[2]
  }
  if(diffs$p_adj_intercept[i]<0.05){
    effects_intercept[i,1:4] <- use_summary$coefficients['countryuk',]
    effects_intercept[i,5] <- use_summary$df[2]
  }
  rsqs$r_squared[i] <- use_summary$r.squared
  rsqs$adj_r_squared[i] <- use_summary$adj.r.squared
}

write.csv(rsqs, filename1)
write.csv(diffs, filename2)

print(paste("mean t value for intercepts jp>uk :", mean(diffs$tval_intercept[diffs$intercept_country=='jp']), 'p < ', max(diffs$p_adj_intercept[diffs$intercept_country=='jp'])))
print(paste("mean t value for slopes jp>uk :", mean(diffs$tval_slope[diffs$slope_country=='jp']), 'p < ', max(diffs$p_adj_slope[diffs$slope_country=='jp'])))
print(paste("mean t value for intercepts uk>jp :", mean(diffs$tval_intercept[diffs$intercept_country=='uk']), 'p < ', max(diffs$p_adj_intercept[diffs$intercept_country=='uk'])))
print("no slope is significantly  uk>jp")
sink()
