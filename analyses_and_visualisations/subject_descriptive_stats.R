#rm(list = ls())
countries = c('uk', 'jp')
datadir <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'

for(country in countries){
  behavroot <- paste0(datadir, country, '/')
  data <- read.csv(paste0(behavroot, 'subs_basic_info.csv'))
  sex <- table(data$sex)
  print(paste(country, 'total N =', dim(data)[1], 'out of whom', sex['female'], 'female and', sex['male'], 'male' ))
  print(paste(country, 'mean age =', mean(data$age), ' sd =', sd(data$age)))
}
