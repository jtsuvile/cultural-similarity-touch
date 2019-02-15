countries = c('uk', 'jp')
datadir <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'

for(country in countries){
  behavroot <- paste0(datadir, country, '/')
  data <- data.frame(read.table(paste(behavroot,'all_subs.txt',sep=''),sep='\n'))
  colnames(data) <- c('subid')
  # the data were saved in slightly different order & differently named files in the different cultures, which is why the following 
  # specifies file and column names separately for both cultures
  if(country=='jp'){
    data[,c("sex","age","weight","height","handedness","education","psychologist","psychiatrist","neurologist","sexual_orientation",
            'mom_race','dad_race','native_country','lived_abroad','time_abroad','home_abroad','when_back')] <- NA
    filename <- 'register.txt'
    first_data_length <- 10
  } else if(country=='uk'){
    data[,c("sex","age","weight","height","handedness","education","psychologist","psychiatrist","neurologist","nationality","describe")] <- NA
    filename <- 'data.txt'
    first_data_length<- 11
  }
  # collect data from each subject and combine
  for(i in c(1:dim(data)[1])){
    subnum <- data$subid[i]
    behavioral_evals <- try(read.table(paste(behavroot,subnum,'/', filename,sep=''),  sep=',', stringsAsFactors = F), silent=T)
    if(class(behavioral_evals)!='try-error'){
      data[i, c(2:(first_data_length+1))] <- behavioral_evals[1:first_data_length]
    }
    if (country=='jp'){
      cultural_bg <- try(read.table(paste(behavroot,subnum,'/cultural_background.txt',sep=''), sep=',', colClasses = c(rep(NA, 7), "NULL"), stringsAsFactors = F), silent=TRUE)
      if(class(cultural_bg)!='try-error'){
        data[i, c(12:18)] <- cultural_bg[1:7]
      }
    }
  }
  
  
  # hide all unused indirect identifiers to comply with Dryad data sharing practices
  # indirect identifiers left in the data are 1) gender, 2) age, and 3) sexual orientation
  data$height <- NA
  data$weight <- NA
  data$handedness <- NA
  data$education <- NA
  data$psychologist <- NA
  data$psychiatrist <- NA
  data$neurologist <- NA
  
  #next, get final subject list by checking cultural background and excluding subjects having unclear culture or failing quality control
  if (country=='jp'){
    #separate out subs with anything unusual in their cultural background
    bad_cultural_subs <- data[!(data$lived_abroad==0&data$mom_race=='japanese'&data$dad_race=='japanese'),c("subid","mom_race","dad_race","lived_abroad","time_abroad")]
    
    #hide Japan-specific indirect identifiers
    culture <- data[,c(1,12:18)] 
    data[,c(12:18)] <- NA 
  } else if (country=='uk'){
    data$describe <- tolower(data$describe) # remove impact of capitalization
    # terms selected manually from responses, trying to identify all that specify british, english, scottish, welsh or irish or a part of those, 
    # even when combined with another qualifier (e.g. white) or typoed (e.g. irush)
    british_cultural_terms <- c('british','welsh','irish','english','scottish','white british','british white','white britiah','white british ','whitw british','black british',
                                'english white','white english','white uk','british asian','asian british','chinese english',"black british african","england",
                                'brrtitish','english.','british ', 'britsh','irush','irish ',"uk","united kingdom ",
                                'yorkshire','british european','middle class english','british pakistan muslim',"british pakistani muslim") 
    #data$describe[!data$describe%in% british_cultural_terms] # if you want to check there are no more relevant terms
    bad_cultural_subs <- data[!data$describe%in%british_cultural_terms,c("subid","nationality","describe")]
    #hide UK-specific indirect identifiers
    culture <- data[,c(1,11:12)]
    data[,11:12] <- NA 
  }
  
  write.table(bad_cultural_subs$subid, paste(behavroot, 'not_clear_culture.txt', sep=''), col.names=FALSE, quote=FALSE, row.names=FALSE)
  write.csv(bad_cultural_subs, paste0(behavroot, 'subinfo_not_clear_culture.csv'), quote=FALSE, row.names=FALSE)
  
  #read in subs who failed QC
  validation <- read.csv(paste0(behavroot, 'qc_fail.txt'), header=FALSE)
  good_subs <- setdiff(data$subid, union(bad_cultural_subs$subid, validation$V1))
  write.table(good_subs, paste(behavroot, 'subs.txt', sep=''), col.names=FALSE, quote=FALSE, row.names=FALSE)
  good_data = data[data$subid%in%good_subs,]
  
  good_culture = culture[culture$subid%in%good_subs,]
  randomised_culture = good_culture[sample(nrow(good_culture), nrow(good_culture)), -1]
  
  #strip text fields off 
  good_data <- good_data[,1:11]
  write.csv(good_data, paste(behavroot, 'subinfo_for_matlab.csv', sep=''), quote=FALSE, row.names=FALSE)
  # data.copy <- data
  # code factors as text for a human-readable csv
  # good_data$handedness <- factor(good_data$handedness, levels=c(1,0), labels=c('right','left'))
  
  # NB: having 1 code female is not a mistake, it's how the values are coded in the online system
  good_data$sex <- factor(good_data$sex, levels=c(1,0,5), labels=c('female','male','other')) # sic! in the system female == 1, male == 0
  # good_data$education <- factor(good_data$education, levels=c(0,1,2), labels=c('elementary','middle','university')) 
  if (country=='jp'){
    good_data$sexual_orientation <- factor(good_data$sexual_orientation, levels=c(1,0,2,3), labels=c('female','male','both','neither')) 
  }
  write.csv(good_data, paste0(behavroot, 'subs_basic_info.csv'), quote=FALSE, row.names=FALSE)
  write.csv(randomised_culture, paste0(behavroot, 'culture_for_good_subs_rand_order.csv'), quote=FALSE, row.names=FALSE)
}

