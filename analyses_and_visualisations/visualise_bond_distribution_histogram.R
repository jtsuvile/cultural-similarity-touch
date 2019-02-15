#rm(list = ls())
library(ggplot2)
library(psych)
require(beanplot)
library(gtable)
library(grid)
# edit these values
dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
figlocation <- "/Users/jtsuvile/Documents/projects/jap-touch/visualizations/"
visualise_what = 'Touch Pleasantness'  # 'Touch Pleasantness' or 'Emotional Bond' 
#sink(paste0("/Users/jtsuvile/Documents/projects/jap-touch/stat_distributions_", visualise_what, ".txt"))

# shouldn't need to edit values below
people <- c('partner','kid', 'mother', 'father', 'sister', 'brother',
            'aunt', 'uncle', 'cousin_f', 'cousin_m' ,
            'friend_f', 'friend_m', 'acq_f', 'acq_m', 'm_kid', 'f_kid',
            'stranger_f', 'stranger_m', 'rand_f_kid', 'rand_m_kid')
people_title <- c('partner','kid', 'mother', 'father', 'sister', 'brother',
                  'aunt', 'uncle', 'female\ncousin', 'male\ncousin' ,
                  'female\nfriend', 'male\nfriend', 'female\nacq.', 'male\nacq.', 'm_kid', 'f_kid',
                  'female\nstranger', 'male\nstranger', 'rand_f_kid', 'rand_m_kid')
people_col_title <- c('Partner','kid', 'Mother', 'Father', 'Sister', 'Brother',
                  'Aunt', 'Uncle', ' Cousin', 'Cousin' ,
                  ' Friend', 'Friend', ' Acq.', 'Acq.', 'm_kid', 'f_kid',
                  ' Stranger', 'Stranger', 'rand_f_kid', 'rand_m_kid')
trim <- c(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18) #removes children who mess up the set! 
m_people <- c('Father', 'Brother',
              'Uncle', 'Cousin',
              'Friend', 'Acq.',
              'Stranger')
f_people <- c('Mother', 'Sister',
              'Aunt', 'Cousin',
              'Friend', 'Acq.',
              'Stranger')

## switch between cases

if(visualise_what=='Touch Pleasantness'){
  file_ending = 'touch_pleasantness'
  jpdata2 = read.table(paste(dataroot,'jp/jp_',file_ending,'.csv',sep=''),sep=",",na.strings = 'NaN')
  endata2 = read.table(paste(dataroot,'uk/uk_', file_ending,'.csv',sep=''),sep=",",na.strings = 'NaN')
  maxcut=10
  mincut=1
} else if (visualise_what == 'Emotional Bond'){
  file_ending = 'emotional_bonds'
  jpdata2 = read.table(paste(dataroot,'jp/jp_',file_ending,'.csv',sep=''),sep=",",na.strings = 'NaN')
  endata2 = read.table(paste(dataroot,'uk/uk_', file_ending,'.csv',sep=''),sep=",",na.strings = 'NaN')
  maxcut=10
  mincut=1
} else {
  break('unknown feature')
}

jp_networks = read.table(paste(dataroot,'jp/jp_socnetwork.csv',sep=''),sep=",")
en_networks = read.table(paste(dataroot,'uk/uk_socnetwork.csv',sep=''),sep=",")

#unique(jpdata2[which(jp_networks==0,arr.ind=T)])
jpdata2[which(jp_networks==0,arr.ind=T)] <- NA
#unique(endata2[which(en_networks==0,arr.ind=T)])
endata2[which(en_networks==0,arr.ind=T)] <- NA
colnames(endata2) <- people
colnames(jpdata2) <- people

endata2['country'] <- 'en'
jpdata2['country'] <- 'jp'

data <- rbind(endata2, jpdata2)
data$country <- factor(data$country)

MWtest_res <- data.frame(statistic = rep(0,length(people)), p.value = rep(0,length(people)), people = people)
for(pers in 1:length(people)){
  MWoutput <- wilcox.test(data[data$country=='jp',pers],data[data$country=='en',pers])
  MWtest_res$statistic[pers] <- MWoutput$statistic
  MWtest_res$p.value[pers] <- MWoutput$p.value
  
}

# Use Mann-Whitney test for discrete variables (bond, pleasantness) 
test_res <- MWtest_res

p_corr <- p.adjust(test_res$p.value)
test_res$p.adjust <- p_corr
test_res$signif <- ' '
test_res$signif[which(test_res$p.adjust < 0.05)] <- '*'
test_res$signif[which(test_res$p.adjust < 0.01)] <- '**'
test_res$signif[which(test_res$p.adjust < 0.01)] <- '***'

data.new <- data
colnames(data.new) <- c('pers_1', 'pers_2', 'pers_3', 'pers_4', 'pers_5', 'pers_6', 'pers_7', 'pers_8','pers_9', 'pers_10','pers_11', 'pers_12', 'pers_13', 'pers_14', 'pers_15', 'pers_16', 'pers_17', 'pers_18', 'pers_19', 'pers_20', 'country')
long_data <- reshape(data.new, varying = c('pers_1', 'pers_3', 'pers_4', 'pers_5', 'pers_6', 'pers_7', 'pers_8','pers_9', 'pers_10','pers_11', 'pers_12', 'pers_13', 'pers_14', 'pers_17', 'pers_18'), timevar = "person", idvar = "id", direction="long", sep = "_")
long_data$country <- factor(long_data$country,levels(long_data$country)[c(2,1)])
long_data$person <- factor(long_data$person, levels=1:20, labels=people_col_title)
long_data <- long_data[, !(names(long_data) %in% c('pers_2', 'pers_15','pers_16','pers_19','pers_20'))]

median_values <-aggregate(pers ~ person*country, data=long_data, FUN=median)
median_jp <- median_values[median_values$country=='jp',]
median_en <- median_values[median_values$country=='en',]


text_annot <- data.frame('label'<- test_res$signif,
                         'person' <- 1:20,
                         'country' <- 'en')
colnames(text_annot) <- c('label','person','country')
text_annot$person <- factor(text_annot$person, levels=1:20, labels=people_col_title)
text_annot <- text_annot[trim,]

p <- ggplot(long_data, aes(pers, fill = country)) + 
  geom_histogram(alpha = 0.4, aes(y = ..density..), 
                 position = 'identity', bins=10, binwidth=1) +
  geom_vline(aes(xintercept=pers-0.1), median_jp, col=rgb(0.97,0.46,0.425,1)) +
  geom_vline(aes(xintercept=pers+0.1), median_en, col=rgb(0,0.75,0.77,1)) +
  facet_wrap(~person, ncol=1, strip.position = "left") +
  scale_x_continuous(name=visualise_what, breaks=seq(1, 10, 1))+
  coord_cartesian(xlim = c(1, 10.1)) +
  scale_y_continuous(breaks=c(0,0.5),position = "right")+
  scale_fill_manual(values=c(rgb(0.97,0.46,0.425,0.8), rgb(0,0.75,0.77,0.8)), labels=c("Japan","UK")) +
  geom_text(data=text_annot,
            mapping = aes(x = 0.6, y = 0.3, label = label),
            hjust=0, col='black') +
  theme_classic()+
  theme(strip.text.y = element_text(angle = 180, 
                                    colour=c('black','red','blue','red','blue','red','blue','red','blue','red','blue','red','blue','red','blue'),
                                    hjust=1),
        strip.background = element_blank(),
        #strip.text = element_blank(),
        panel.grid = element_blank(),
        panel.spacing = unit(0, "lines"),
        text=element_text(size=16),
        legend.position = 'bottom')

pdf(paste(figlocation,file_ending,'_distribution_comparison_histogram.pdf', sep=''),
    width=6, height=10)
p
dev.off()

print(visualise_what)
print(test_res)
#sink()
