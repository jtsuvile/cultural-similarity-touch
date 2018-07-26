library(ggplot2)
require(gridExtra)
require(grid)  
library(reshape)
library(QuantPsyc)
library(relaimpo)
source('../bodySPM/summarySE.R')
source('../bodySPM/multiplot.R')

dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
trim = c(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18) # removes children who mess up the set!
people <- c('Partner', 'kid', 'Mother', 'Father', 'Sister', 'Brother', 
            'Aunt', 'Uncle', 'F_Cousin', 'M_Cousin',
            'F_Friend', 'M_Friend', 'F_Acq', 'M_Acq', 'm kid', 'f kid', 
            'F_Stranger', 'M_Stranger', 'rand f kid', 'rand m kid')#, 'check')
interesting_people <- people[trim]  

whole_fig_size = 178524
inside_mask = 89129

countries <- c('uk','jp')

# load & clean up data
for(country in countries){
  subjects <- read.csv(paste(dataroot, country, '/subs_basic_info.csv', sep=''),header=TRUE)
  socnetwork <- read.csv(paste(dataroot, country, '/', country, '_socnetwork.csv', sep=''), header=FALSE)
  sli <- read.csv(paste(dataroot, country, '/area_new.csv', sep=''), header=FALSE)
  bonds <- read.csv(paste(dataroot, country, '/', country, '_emotional_bonds.csv', sep=''), header=F, na.strings = 'NaN')
  pleasantness <- read.csv(paste(dataroot, country, '/', country, '_touch_pleasantness.csv', sep=''), header=FALSE,sep=",",na.strings = 'NaN')
  
  ## change 0 to NA in nonexistent persons
  sli[socnetwork==0] = NA
  bonds[socnetwork==0] = NA
  pleasantness[socnetwork==0] = NA
  #massage data to proper shape
  bonds_trim <- bonds[,trim]
  colnames(bonds_trim) <- interesting_people
  bonds_trim$subid <- subjects$subid
  pleasantness_trim <- pleasantness[,trim]
  colnames(pleasantness_trim) <- interesting_people
  pleasantness_trim$subid <- subjects$subid
  sli_trim <- sli[,trim]
  colnames(sli_trim) <- interesting_people
  sli_trim$subid <- subjects$subid
  sli_trim$subsex <- subjects$sex
  bonds_long <- melt(bonds_trim, id=c("subid"),variable_name='person',na.rm=TRUE)
  colnames(bonds_long) <- c('subid','person','bond')
  sli_long <- melt(sli_trim, id=c("subid",'subsex'),variable_name='person',na.rm=TRUE)
  colnames(sli_long) <- c('subid','subsex','person','touchability')
  pleasantness_long <- melt(pleasantness_trim, id=c("subid"),variable_name='person',na.rm=TRUE)
  colnames(pleasantness_long) <- c('subid','person','pleasantness')
  temp <- merge(sli_long, bonds_long, by=c("subid","person"))
  temp$country <- country
  total <- merge(temp, pleasantness_long, by=c('subid','person'))
  total$touchability_proportion <- total$touchability/inside_mask
  if(country=='uk'){
    total_uk <- total
    filename <- paste0(dataroot, country, '/total_uk.Rdata')
    saveRDS(total_uk, filename)
  } else if (country=='jp'){
    total_jp <- total
    filename <- paste0(dataroot, country, '/total_jp.Rdata')
    saveRDS(total_jp, filename)
  } else {
    print("problem with country name")
  }
}
