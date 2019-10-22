*Difference in differences: common trends assumption

clear all
capture cd "<\\toaster\homes\a\v\avarga5\nt>"
set more off

capture prog drop didtrends
program didtrends, rclass
syntax, coef(real)
drop _all

***********************************Set up data for problem*****************************
*panel of 300 individuals
	set obs 300
	gen indiv = _n
	
*over ten periods and group
	expand 10
	bysort indiv:gen year=_n

*make control and treatment groups
	gen treat = 0
		replace treat = 1 if indiv > 150
		
*define treatment period
	gen post = 0 
		replace post = 1 if year >= 6
		
*interact post and treatment		
	gen treat_post = treat * post 
	gen trend = year *treat
	gen e = rnormal(0,1)
	
*true parameters
	gen beta0 = 1.0
	gen beta1 = 1.5 
	gen beta2 = 2.0
	gen beta3 = 3.0
	gen y = beta0 + `coef'*trend + beta1*treat + beta2*post + beta3*treat_post + e

*Panel variables
xtset indiv year

********************************Regression time*****************************************
reg y treat post treat_post
return scalar beta3 = _b[treat_post]
return scalar se3 = _se[treat_post]
return scalar co = `coef'

******************************Hypothesis testing****************************************
*test H0: beat3 = 3 under alpha = 0.05 after estimation
test _b[treat_post] = 3 
local pvalue = r(p) 
if `pvalue'<0.05 {
	return scalar reject  = 1
}  
else {
	return scalar reject = 0
}

end

**********************************Simulation********************************************
*runs 7 simulations with 500 replications

forvalues i = 1(1)7{
    local coef = (`i'-4)*.2
	simulate co=r(co) beta3=r(beta3) se3=r(se3) reject_null=r(reject), saving(DiD_`i'.dta, replace) reps(500): didtrends, coef(`coef')
}

clear /* you have no idea how long it took me to figure out I had to put a clear here*/
forvalues i = 1(1)7{
	append using DiD_`i'.dta
	erase DiD_`i'.dta
}		 
	
***************************Summary Statistics*******************************************
*table for rejections of null
tabstat beta3 reject_null, by(co) statistics (mean sd sum count) columns(statistics) longstub


*Results* 
/*

co           variable |      mean        sd       sum         N
----------------------+----------------------------------------
-.600000        beta3 |  .0018105  .0697213  .9052718       500
          reject_null |         1         0       500       500
----------------------+----------------------------------------
-.400000        beta3 |  1.004374   .073663  502.1869       500
          reject_null |         1         0       500       500
----------------------+----------------------------------------
-.200000        beta3 |  1.994638  .0724779  997.3192       500
          reject_null |         1         0       500       500
----------------------+----------------------------------------
0               beta3 |  2.997288  .0746169  1498.644       500
          reject_null |      .046  .2096949        23       500
----------------------+----------------------------------------
.2000000        beta3 |  3.998989  .0738365  1999.494       500
          reject_null |         1         0       500       500
----------------------+----------------------------------------
.4000000        beta3 |  5.000046  .0699901  2500.023       500
          reject_null |         1         0       500       500
----------------------+----------------------------------------
.6000000        beta3 |  5.997368  .0757184  2998.684       500
          reject_null |         1         0       500       500
----------------------+----------------------------------------
Total           beta3 |  2.999216  2.000354  10497.26      3500
          reject_null |  .8637143  .3431407      3023      3500
---------------------------------------------------------------

The table shows the mean estimates of the coefficient of the varibale of interest
beta3 and how many times the null was rejected when considering varying trends. 
 
As you can see, when the coefficeint on trend is 0 the estimated beta3 is close to the 
real value 3, in this case 2.997288. 

Thus we reject the null 23 out of 500 cases. With the trend considered,
the beta3 estimates are significantly different from 3 and the null is rejected 
100% of the time.

*/
