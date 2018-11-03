/* 
Data encoding process for my final paper in ECON 385: Regression and 
Simulation class at DePauw University taught by Professor Humberto Barreto
at DePauw University

@author: Shuto Araki
@date: November 28, 2017.
*/

clear

set mat 800

* Utilizing raw dataset from CPS Internet and Computer Use Supplement 2015
use "I:\17181-ECON385A\SHUTOARAKI_2020\Paper\cps_00007.dta"


	/*
	---------- DATA RECODING -----------
	*/
	
* Putting niu and ill-formatted data into missing values
replace earnweek = . if earnweek == 9999.99 // niu -> missing value because of exclusion of CEOs
replace earnweek = . if earnweek == 2884.61 // Higher income earners compressed into this data point
drop if cinethp == 99 // niu -> dropping because it's small

* Encoding educ to the years of education that focuses on uneducated samples
gen educYears = 0 if educ == 000 | educ == 001 | educ == 002
replace educYears = 4 if educ == 010 | educ == 011 | educ == 012 | educ == 013 | educ == 014
replace educYears = 6 if educ == 020 | educ == 021 | educ == 022
replace educYears = 8 if educ == 030 | educ == 031 | educ == 032
replace educYears = 9 if educ == 040
replace educYears = 10 if educ == 050
replace educYears = 11 if educ == 060
replace educYears = 11.5 if educ == 071 | educ == 072
replace educYears = 12 if educ == 070 | educ == 073
replace educYears = 13 if educ == 080 | educ == 081

replace educYears = 14  if educ==091
replace educYears = 14  if educ==092
replace educYears = 16  if educ==111
replace educYears = 18  if educ>=123

gen compUse = 1 if cinethp == 02
replace compUse = 0 if cinethp == 01

* probit analysis
probit compUse educYears

margins, at(educYears = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18))

marginsplot

* Dropping "educated" sample who have more than 12 years of education
drop if educ == 080 | educ == 081 | educ == 090 | educ == 091 | educ == 092 | educ == 100 | educ == 110 | educ == 111 | educ == 120 | educ == 121 | educ == 122 | educ == 123 | educ == 124 | educ == 125 | educ == 999

* For the data summary

gen white = 1 if race == 100
replace white = 0 if race != 100

gen black = 1 if race == 200
replace black = 0 if race != 200

gen asian = 1 if race == 651
replace asian = 0 if race != 651

gen hispanic = 1 if hispan != 000
replace hispanic = 0 if hispan == 000

* Marital status (for the interaction term)
gen married = 1 if marst == 1 | marst == 2
replace married = 0 if marst != 1 & marst != 2

* Female (for the interaction term)
gen female = 1 if sex == 2
replace female = 0 if sex == 1

* Interaction term
gen femaleMarried = female*married

* Metropolitan residency
gen metropolitan = 0 if metro == 0 | metro == 1 | metro == 9
replace metropolitan = 1 if metro == 2 | metro == 3 | metro == 4

* Computer-related occupation (1 = yes)
gen compJob = 1 if occ == 0110 | occ == 1000 | occ == 1005 | occ == 1006 | occ == 1007 | occ == 1010 | occ == 1020 | occ == 1030 | occ == 1050 | occ == 1105 | occ == 1106 | occ == 1107 | occ == 1400 | occ == 5800 | occ == 7010 | occ == 7900
replace compJob = 0 if occ != 0110 & occ != 1000 & occ != 1005 & occ != 1006 & occ != 1007 & occ != 1010 & occ != 1020 & occ != 1030 & occ != 1050 & occ != 1105 & occ != 1106 & occ != 1107 & occ != 1400 & occ != 5800 & occ != 7010 & occ != 7900

* Computer-related industries (1 = yes)
gen compInd = 1 if ind == 6672 | ind == 3365 | ind == 7380
replace compInd = 0 if ind != 6672 & ind != 3365 & ind != 7380

* Creating the independent variable for the proper functional form
gen lnEarn = ln(earnweek)

* Creating experience and experience squared
gen exp = age - educYears - 6
gen expSq = exp^2


	/*
	---------- TABLES AND FIGURES -----------
	*/

* Creating histograms and tables used in the paper

* Figure 1.
hist earnweek, freq

* Table 1.
sum earnweek female exp educYears compUse white black asian hispanic married femaleMarried metropolitan compJob compInd

* Figure 2.
hist educYears if earnweek != ., freq


	/*
	---------- REGRESSION ANALYSIS -----------
	*/

* Loading estimates display package
ssc install estout

* Model 1: Raw differential
eststo: regress lnEarn i.cinethp

di e(r2_a) // Adjusted R^2

* Model 2
eststo: regress lnEarn i.cinethp educYears

di e(r2_a)

* Model 3
eststo: regress lnEarn i.cinethp educYears exp expSq i.race i.hispan i.sex i.marst femaleMarried i.metro

di e(r2_a)

* Model 4
eststo: regress lnEarn i.cinethp educYears exp expSq i.race i.hispan i.sex i.marst femaleMarried i.metro i.occ i.ind

* Breusch-Pagan test for Model 4
hettest i.cinethp educYears exp expSq i.race i.hispan i.sex i.marst femaleMarried i.metro i.occ i.ind

di e(r2_a)

* Model 5
eststo: regress lnEarn i.cinethp educYears exp expSq i.race i.hispan i.sex i.marst femaleMarried i.metro i.occ i.ind [pw=wtfinl]

di e(r2_a)



* Store the table result in regressionTable.rtf
esttab using HSRegression.rtf, se



