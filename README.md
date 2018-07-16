## Some idiosyncracies of the data as it is collected

## Order of stimuli in raw data
Mismatch is fixed in write_bodies_2.m for colouring data and in save_bond_etc.m for background data, so all the .mat files created by scripts should have both sets conforming to stimulus order in the *British* data

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
This is the order in raw data, it is harmonized in save_bond_etc.m so that Japanese data order becomes EN data order

### EN
1. Age
2. Lapse
3. Sex
4. Bond
5. Pleasant
6. Assumed

### JP
1. Age
2. Lapse
3. Lapse scale (days, weeks, months, years)
4. Sex
5. Bond
6. Pleasant

