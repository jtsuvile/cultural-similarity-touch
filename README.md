# Data analysis 

## Reading in the data and quality control

* get\_sub\_info.R
* workflow\_1\_read\_in\_data.m

NB: these steps have already been completed for the shared data to strip some potentially identifying information away from the shared data.

### Subject lists 
* Full set of subjects 

  All subjects who completed the experiment are listed at all\_subs.txt  

* Quality Control
  
  Data quality control for the subject-wise touch area maps. Subjects were excluded if they had left more than X bodies completely empty or if there was evidence of clearly colouring outside the body outline or other scribbling. In the Japanese data set there was an additional control task, where the subjects were told to only colour in the hair of the figure. Leaving hair uncoloured or colouring areas outside of the hair led to that subject being excluded from the final data set. Latter was defined visually by RK and JS. Subjects excluded due to QC are listed at qc\_fail.txt 

* Control for cultural affiliation

  Since the aim of the experiment was to compare two cultures, the subjects were further screened for cultural background. Subjects excluded due to cultural background are listed at not\_clear\_culture.txt

  To be included in the final Japanese sample the subjects had to 
    * report own ethnicity as 'Japanese'
    * report both parents' ethnicity as 'Japanese'
    * not have spent more than a year abroad 

  To be included in the final British sample the subjects had to 
    * report own ethnicity or cultural affiliation as 'British', 'English', 'Irish' or 'Welsh'
    * report having English as first language

* Final full samples (all_subs withour subjects in qc\_fail or not\_clear\_culture)

    subs.txt

## Preprocessing

* workflow\_2\_preprocess.m

## Analyses and visualisations

* Participant statistics
  - foo
  - country-wise distributions of emotional bond, TI, pleasantness:
* Topographies
  - Differences in topographies: two\_sample\_prop\_test\_country\_comparison.m 
  - Plotting: tmaps\_tworows.m
* Linear regression
  - statistical analysis & plotting: statistical_analysis_bond_sli.R
  - gender\_trellis\_scatter.m for bond vs TI by toucher sex 
* ROI-analysis
  - Slopes & statistical analysis:
  - Plotting:
  - Final plot combined from ROI definitions and ROI_output in Adobe Illustrator
* Gender differences
  - gender\_plots.R for the comparison between specific social network members (mother/father, sister/brother etc.) and interaction plot
  - gender\_trellis_scatter.m for bond vs TI by toucher sex 

