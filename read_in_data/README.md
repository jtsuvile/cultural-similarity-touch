# Some idiosyncracies of the data as it is collected
There are some discrepancies in which order social network members were listed and the exact social network members (familiar f/m child vs niece/nephew). These do not impact the final analyses since children are not included in that and the analysis code corrects for the differences in the order. If you are only interested in steps after preprocessing, you do not need to take the following into account. The following discrepancies are only relevant when handling the raw data.

## Order of stimuli in raw data
Mismatch is fixed in write\_bodies\_2.m for colouring data and in save\_bond\_etc.m for background data, so all the .mat files created by scripts should have both sets conforming to stimulus order in the *British* data

### EN
1. Partner
2. Own child 
3. Mother
4. Father
5. Sister
6. Brother
7. Aunt
8. Uncle
9. Female Cousin
10. Male Cousin
11. Female Friend
12. Male Friend
13. Female Acquaintance
14. Male Acquaintance 
15. Familiar Female Child (not your own, under elementary school age)
16. Familiar Male Child (not your own, under elementary school age)
17. Female Stranger (approx your own age)
18. Male Stranger (approx your own age)
19. Unknown Female Child (under elementary school age)
20. Unknown Male Child (under elementary school age)

### JP
1. Partner
2. Own child 
3. Mother
4. Father
5. Sister
6. Brother
7. Niece (this is different)
8. Nephew (this is different)
9. Aunt
10. Uncle
11. Female Cousin
12. Male Cousin
13. Female Friend
14. Male Friend
15. Female Acquaintance
16. Male Acquaintance 
17. Female Stranger (approx your own age)
18. Male Stranger (approx your own age)
19. Unknown Female Child (under elementary school age)
20. Unknown Male Child (under elementary school age)


## Order of background information 
This is the order in raw data, it is harmonized in save\_bond\_etc.m so that Japanese data order becomes EN data order

### EN
1. Age
2. Lapse
3. Sex (only collected for partners and own children, other social network members have a predefined sex)
4. Emotional bond
5. Pleasant (how pleasant do you find it when this person touches you)
6. Assumed (how pleasant do you assume this person finds it when you touch them)

### JP
1. Age
2. Lapse
3. Lapse scale (days, weeks, months, years)
4. Sex (only collected for partners and own children, other social network members have a predefined sex)
5. Emotional Bond
6. Pleasant (how pleasant do you find it when this person touches you)

