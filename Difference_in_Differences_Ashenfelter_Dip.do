*Difference in differences: Ashenfelter's Dip

clear all
capture cd "<\\toaster\homes\a\v\avarga5\nt>"
set more off

********************************************************************************
*************************************Part I*************************************
********************************************************************************
capture prog drop PartI
program PartI, rclass
drop _all

*set observations
set obs 200
gen indiv = _n

*individual fixed effect
gen alpha_i = rnormal(2,4)
expand 10

*year
bysort indiv: gen year = _n

*year fixed effects
bysort year: gen alpha_tt = rnormal(1,2)
*but we want every year one to have same alpha-->
bysort year: egen alpha_t = mean(alpha_tt)
drop alpha_tt
sort indiv year

*true parameter
gen theta = 5

*gen treatment
gen treat_it = 0
replace treat_it = uniform() <= 0.5 if year == 7
replace treat_it = treat_it[_n-1] if year > 7

*gen errors
gen u_it = rnormal(0,2)
gen e_it = u_it if year == 1
replace e_it = 0.8 * u_it + 0.2 * e_it[_n-1] if year != 1

*gen y
gen y_it = alpha_i + alpha_t + theta * treat_it + e_it

*set panel data
xtset indiv year

*******************************Case 1: Errors are iid***************************
xtreg y_it treat_it i.year, fe
return scalar theta_1 = _b[treat_it]
return scalar se_1 = _se[treat_it]

*test hypothesis, h0; theta = 5
test _b[treat_it] = 5
local pvalue_1 = r(p)
if `pvalue_1' < 0.05{
	return scalar reject_1 = 1
}
else {
	return scalar reject_1 = 0
}

********************************Case 2: Errors heteroskedastic robust***********
areg y_it treat_it i.year, absorb(indiv) vce(robust)
return scalar theta_2 = _b[treat_it]
return scalar se_2 = _se[treat_it]

*test hypothesis, h0: theta =5
test _b[treat_it] = 5
local pvalue_2 = r(p)
if `pvalue_2' < 0.05 {
	return scalar reject_2 = 1
}
else {
	return scalar reject_2 = 0
}

*******************************Case 3: Errors clustered*************************
xtreg y_it treat_it i.year, fe vce(cluster indiv)
return scalar theta_3 = _b[treat_it]
return scalar se_3 = _se[treat_it]

*test hypothesis
test _b[treat_it] = 5
local pvalue_3 = r(p)
if `pvalue_3' < 0.05 {
	return scalar reject_3 = 1
}
else {
	return scalar reject_3 = 0
}

end

***********************************Simulation: Part I***************************
simulate theta_1 = r(theta_1) se_1 = r(se_1) reject_1 = r(reject_1) ///
theta_2 = r(theta_2) se_2 = r(se_2) reject_2 = r(reject_2) ///
theta_3 = r(theta_3) se_3 = r(se_3) reject_3 = r(reject_3), ///
saving(PartI.dta, replace) reps(500): PartI

tabstat theta_1 theta_2 theta_3 se_1 se_2 se_3 reject_1 reject_2 reject_3, ///
statistics(n sum mean sd min max) col(stat) long

erase PartI.dta
/*
    variable |         N       sum      mean        sd       min       max
-------------+------------------------------------------------------------
     theta_1 |       500  2498.261  4.996523  .1775241  4.446484  5.641209
     theta_2 |       500  2498.261  4.996523  .1775241  4.446484  5.641209
     theta_3 |       500  2498.261  4.996523  .1775241  4.446484  5.641209
        se_1 |       500  74.80568  .1496114  .0026874  .1432091  .1573221
        se_2 |       500  74.30645  .1486129   .002781  .1418932  .1566732
        se_3 |       500  86.99661  .1739932  .0085052  .1502399  .1991136
    reject_1 |       500        48      .096  .2948863         0         1
    reject_2 |       500        48      .096  .2948863         0         1
    reject_3 |       500        27      .054  .2262441         0         1
--------------------------------------------------------------------------
What do you learn?

If we compare the treatment effect values of the iid, heteroskedastic robust and 
clustered errors, we see that all three thetas have the same value of 2498.261.

However, if we look at the coefficient values on the standard errors themselves
the se_2 (robust) has the smallest value at 74.306 with se_1 (iid) a close second
at 74.806. Se_3 (clustered) has the largest standard errors at 86.998.

With the se_1 (iid) and se_2 (robust) values being so close it is no surprise  
that the model rejects the H0 48/500 or 9.6% of the time for each. On the other 
hand, se_3 (clustered) rejects the H0 27/500 or 5.4% of the time
*/

********************************************************************************
*************************************Part II************************************
********************************************************************************
clear
capture prog drop PartII
program PartII, rclass
drop _all

*set observations
set obs 200
gen indiv = _n

*individual fixed effect
gen alpha_i = rnormal(2,4)
expand 10

*year
bysort indiv: gen year = _n

*year fixed effects
bysort year: gen alpha_tt = rnormal(1,2)
*but we want every year one to have same alpha-->
bysort year: egen alpha_t = mean(alpha_tt)
drop alpha_tt
sort indiv year

*true parameter
gen theta = 5

*gen errors
gen u_it = rnormal(0,2)
gen e_it = u_it if year == 1
replace e_it = 0.8 * u_it + 0.2 * e_it[_n-1] if year != 1

*gen treatment
gen y_temp = alpha_i + alpha_t + e_it
egen y_med = median(y_temp) if year == 6
gen treat_it = 0
replace treat_it = 1 if y_temp < y_med & year ==7 
replace treat_it = treat_it[_n-1] if year > 7
drop y_temp y_med

*gen y
gen y_it = alpha_i + alpha_t + theta * treat_it + e_it

*set panel data
xtset indiv year

**************************************Errors clustered**************************
xtreg y_it treat_it i.year, fe vce(cluster indiv)
return scalar theta = _b[treat_it]
return scalar se = _se[treat_it]

*test hypothesis
test _b[treat_it] = 5
local pvalue = r(p)
if `pvalue' < 0.05 {
	return scalar reject = 1
}
else {
	return scalar reject = 0
}

end

***********************************Simulation: Part II**************************
simulate theta = r(theta) se = r(se) reject = r(reject), ///
saving(PartII.dta, replace) reps(500): PartII

tabstat theta se reject, stat(n sum mean sd min max) col(stat) long

erase PartII.dta

/*
    variable |         N       sum      mean        sd       min       max
-------------+------------------------------------------------------------
       theta |       500  2503.646  5.007293   .273351  3.846286  5.795259
          se |       500  91.14257  .1822851  .0087347  .1598368  .2098206
      reject |       500        93      .186  .3894964         0         1
--------------------------------------------------------------------------
What do you learn?

Having the treatment dependent on previous period outcomes keeps the value of the
treatment effect, theta, about the same at 2503.646.

The standard errors at 91.143 are also close to the original values seen in PartI.

However, when we have the treatment dependent on previous outcomes, the number of
rejections increases three fold to 93/500 or 18.6% from 5.4% when treatment was
randomly assigned. This situation describes "Ashenfelter's Dip" where the outcomes 
of the treatment group experience a dip prior to treatment, like losing your job 
and then going to a training course to the likelihood of getting another job (treat).
This phenomenon biases the results and makes the tretment seem like it has a larger
effect than reality.
*/

********************************************************************************
*************************************Part III***********************************
********************************************************************************
clear
capture prog drop PartIII
program PartIII, rclass
drop _all

*set observations
set obs 200
gen indiv = _n

*individual fixed effect
gen alpha_i = rnormal(2,4)
expand 10

*year
bysort indiv: gen year = _n

*year fixed effects
bysort year: gen alpha_tt = rnormal(1,2)
*but we want every year one to have same alpha-->
bysort year: egen alpha_t = mean(alpha_tt)
drop alpha_tt
sort indiv year

*true parameter
gen theta = 5

*gen errors
gen u_it = rnormal(0,2)
gen e_it = u_it if year == 1
replace e_it = 0.8 * u_it + 0.2 * e_it[_n-1] if year != 1

*gen treatment
gen y_temp = alpha_i + alpha_t + e_it
egen y_med = median(y_temp) if year == 6
gen treat_it = 0
replace treat_it = 1 if y_temp < y_med & year ==7 
replace treat_it = treat_it[_n-1] if year > 7

*gen pre treatment
gen pre_treat = 0 
replace pre_treat = 1 if y_temp < y_med & year ==7 

*gen y
gen y_it = alpha_i + alpha_t + theta * treat_it + e_it

*set panel data
xtset indiv year

********************************Errors clustered and pre_treat******************
xtreg y_it treat_it pre_treat i.year, fe vce(cluster indiv)
return scalar theta = _b[pre_treat]
return scalar se = _se[pre_treat]

*test hypothesis
test _b[pre_treat] = 0
local pvalue = r(p)
if `pvalue' < 0.05 {
	return scalar reject = 1
}
else {
	return scalar reject = 0
}

end

***********************************Simulation: Part III**************************
simulate theta = r(theta) se = r(se) reject = r(reject), ///
saving(PartIII.dta, replace) reps(500): PartIII

tabstat theta se reject, stat(n sum mean sd min max) col(stat) long

erase PartIII.dta

/*
    variable |         N       sum      mean        sd       min       max
-------------+------------------------------------------------------------
       theta |       500  -.220434 -.0004409  .2419443 -.8330304  .5918832
          se |       500   81.5026  .1630052  .0082004  .1351871  .1828564
      reject |       500        99      .198  .3988912         0         1
--------------------------------------------------------------------------
How often does this "falsification test" successfully diagnose that the model is 
misspecified?

In this part we are getting the theta on pre_treatment to try and discern if there
are similar trends in the pre and post treatment groups. Here we can say that the 
falsification test successfully diagnoses the misspecification 19.8% of the time.
*/


********************************************************************************
*************************************Part IV************************************
********************************************************************************
clear
capture prog drop PartIV
program PartIV, rclass
drop _all

*set observations
set obs 200
gen indiv = _n

*individual fixed effect
gen alpha_i = rnormal(2,4)
expand 10

*year
bysort indiv: gen year = _n

*year fixed effects
bysort year: gen alpha_tt = rnormal(1,2)
*but we want every year one to have same alpha-->
bysort year: egen alpha_t = mean(alpha_tt)
drop alpha_tt
sort indiv year

*true parameter
gen theta = 5

*gen errors
gen u_it = rnormal(0,2)
gen e_it = u_it if year == 1
replace e_it = 0.8 * u_it + 0.2 * e_it[_n-1] if year != 1

*gen treatment
gen y_temp = alpha_i + alpha_t + e_it
egen y_med = median(y_temp) if year == 6
gen treat_it = 0
replace treat_it = 1 if y_temp < y_med & year ==7 
replace treat_it = treat_it[_n-1] if year > 7

*gen pre treatment
gen pre_treat = 0 
replace pre_treat = 1 if y_temp < y_med & year ==7 

*gen y
gen y_it = alpha_i + alpha_t + theta * treat_it + e_it

*set panel data
xtset indiv year

**********************Errors clustered and control for pre_treat****************
xtreg y_it treat_it pre_treat i.year, fe vce(cluster indiv)
return scalar theta = _b[treat_it]
return scalar se = _se[treat_it]

*test hypothesis
test _b[treat_it] = 5
local pvalue = r(p)
if `pvalue' < 0.05 {
	return scalar reject = 1
}
else {
	return scalar reject = 0
}

end

***********************************Simulation: Part IV**************************
simulate theta = r(theta) se = r(se) reject = r(reject), ///
saving(PartIV.dta, replace) reps(500): PartIV

tabstat theta se reject, stat(n sum mean sd min max) col(stat) long

erase PartIV.dta

/*
    variable |         N       sum      mean        sd       min       max
-------------+------------------------------------------------------------
       theta |       500  2501.363  5.002727  .2703353  4.154127  5.780653
          se |       500  90.76632  .1815326  .0094357  .1585968  .2113034
      reject |       500        84      .168  .3742407         0         1
--------------------------------------------------------------------------
Would controlling for the outcome in period 6 be a useful way of addressing the 
bias observed in PartII?

Controlling for the outcome in period 6 (i.e. controlling for Ashenfelter's Dip)
addresses some of the observed bias as seen in the change in rejection rate. In 
PartII we have a rejection rate of 18.6 and by controlling for period 6 the rejection
rate decreases to 16.8%
*/
