#rm(list = ls())
library(ggplot2)
library(psych)
require(beanplot)

# edit these values
dataroot <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/data/'
figlocation <- '/Volumes/SCRsocbrain/cultural_comparison_code_test/figs/'
visualise_what = 'Touchability Index' # 'Touch Pleasantness' or 'Emotional Bond' or 'Touchability Index'
sink(paste0("/Users/jtsuvile/Documents/projects/jap-touch/stat_distributions_", visualise_what, ".txt"))


# shouldn't need to edit values below
whole_fig_size = 178524
inside_mask = 89129

people <- c('partner','kid', 'mother', 'father', 'sister', 'brother',
            'aunt', 'uncle', 'cousin_f', 'cousin_m' ,
            'friend_f', 'friend_m', 'acq_f', 'acq_m', 'm_kid', 'f_kid',
            'stranger_f', 'stranger_m', 'rand_f_kid', 'rand_m_kid')
people_title <- c('partner','kid', 'mother', 'father', 'sister', 'brother',
                  'aunt', 'uncle', 'female\ncousin', 'male\ncousin' ,
                  'female\nfriend', 'male\nfriend', 'female\nacq.', 'male\nacq.', 'm_kid', 'f_kid',
                  'female\nstranger', 'male\nstranger', 'rand_f_kid', 'rand_m_kid')
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
} else if ( visualise_what == 'Touchability Index'){
  file_ending = 'area_new'
  jpdata2 = read.table(paste(dataroot,'jp/',file_ending,'.csv',sep=''),sep=",",na.strings = 'NaN')
  endata2 = read.table(paste(dataroot,'uk/', file_ending,'.csv',sep=''),sep=",",na.strings = 'NaN')
  maxcut=1
  mincut=0
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

if(visualise_what == 'Touchability Index'){
  jpdata_orig = jpdata2
  endata_orig = endata2
  jpdata2 = jpdata2/inside_mask
  endata2 = endata2/inside_mask
}

endata2['country'] <- 'en'
jpdata2['country'] <- 'jp'

data <- rbind(endata2, jpdata2)
data$country <- factor(data$country)

KWtest_res <- data.frame(statistic = rep(0,length(people)), p.value = rep(0,length(people)), people = people)
MWtest_res <- data.frame(statistic = rep(0,length(people)), p.value = rep(0,length(people)), people = people)
KStest_res <- data.frame(statistic = rep(0,length(people)), p.value = rep(0,length(people)), people = people)


for(pers in 1:length(people)){
  KWoutput <- kruskal.test(data[,pers], data$country)
  KWtest_res$statistic[pers] <- KWoutput$statistic
  KWtest_res$p.value[pers] <- KWoutput$p.value
  
  MWoutput <- wilcox.test(data[data$country=='jp',pers],data[data$country=='en',pers])
  MWtest_res$statistic[pers] <- MWoutput$statistic
  MWtest_res$p.value[pers] <- MWoutput$p.value
  
  KSoutput <- ks.test(data[data$country=='jp',pers],data[data$country=='en',pers])
  KStest_res$statistic[pers] <- KSoutput$statistic
  KStest_res$p.value[pers] <- KSoutput$p.value
}

# Use Mann-Whitney test for discrete variables (bond, pleasantness) and Kruskal-Wallis for contiuous variable (TI)
if(visualise_what == 'Touchability Index'){
  test_res <- KStest_res
} else {
  test_res <- MWtest_res
}

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
long_data$inverse_person <- 16-long_data$person

pers = 1
data1 <- jpdata2[,pers]
data2 <- endata2[,pers]
limit=c(0,1)

pdf(paste(figlocation,file_ending,'_distribution_comparison_vertical.pdf', sep=''), 
    width=6, height=10)
par(xpd = T, mar = par()$mar + c(3,4,1,1))
beanplot(pers ~ country*inverse_person, data=long_data,
         main = ' ', side = "both", xlab=' ', horizontal=TRUE,
         col = list(rgb(0.97,0.46,0.425,0.8),rgb(0,0.75,0.77,0.8)), #248, 118, 109 # 0, 191, 196)
         axes=F, cutmax=maxcut, cutmin=mincut, what=c(0,1,1,0),
         cex=2)
axis(2, at=1:15,  labels=rep('',15), padj=0.5, cex.axis=1.5,
     col.axis="black", las=2)
axis(2, at=seq(2,14,2),  labels=rev(f_people), padj=0.5, cex.axis=1.5,
     col.axis="red", las= 2)
axis(2, at=seq(1,14,2),  labels=rev(m_people), padj=0.5, cex.axis=1.5,
     col.axis="blue", las=2)
axis(2, at=15,  labels='Partner', padj=0.5, cex.axis=1.5,
     col.axis="black", las=2)
#axis(1, at=1:15,  labels=people_title[trim], padj=0.5, cex.axis=0.95,
#     col.axis="red")
if(visualise_what == 'Touchability Index'){
  text(1.02,1:15, rev(test_res$signif[trim]), cex=2, adj=0)
  axis(1, at=seq(mincut,maxcut,0.2), labels=seq(mincut,maxcut,0.2), cex.axis=1.5, pos=0.5)
  legend(-.4,0, fill = c(rgb(0,0.75,0.77,0.8),rgb(0.97,0.46,0.425,0.8)),
         legend = c("UK","Japan"), box.lty=0, cex=1.5,y.intersp=0.8)
} else {
  text(10.2, 1:15, rev(test_res$signif[trim]), cex=2, adj=0)
  axis(1, at=mincut:maxcut, labels=mincut:maxcut, cex.axis=1.37, pos=0.5)
  legend(-2.5, 0, fill = c(rgb(0,0.75,0.77,0.8), rgb(0.97,0.46,0.425,0.8)),
         legend = c("UK","Japan"), box.lty=0, cex=1.5,y.intersp=0.8)
}
title(xlab=visualise_what, line=2, cex.lab=1.5)
title(ylab='Person', line=5.5, cex.lab=1.5)
#par(mar=c(20, 4, 20, 2) + 0.1)
dev.off()

print(visualise_what)
print(test_res)
sink()
