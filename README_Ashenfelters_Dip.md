# Difference_in_Differences (DiD)

Here we will look at a common phenomenon in DiD called Ashenfelter's Dip

Problem: 
We want to examine how the estimate of our parameter of interest will be biased when the treatment group and control group have different trends

We will estimate the general DiD model: 

Y_it = αlpha_i + αlpha_t + θTreat_it + e_it

such that
αlpha_i are individual fixed effects
αlpha_t are year fixed effects 
T_it is an indicator variable that takes a one when an individual has been treated

Part 1: Check for autocorrelation
1) Simulate a model in which there are ten periods
  a) such that αlpha_i ∼ N(2, 4), αlpha_t ∼ N(1, 2), θ = 5, e_it = 0.8uit + 0.2e_it−1 and u ∼ N(0, 2) except in period 1 when e_it = u_it
  b) Let a permanent treatment be randomly assigned in period 7 with a probability of 0.5 (such that T reatit = 1 for treated individuals in the treatment period and all subsequent periods). 
2) Run 500 replications with a panel of 200 individuals where you save the estimated treatment effect, its standard error estimate, and 
whether you reject H0 : θ = 5 at the five-percent level.
  a) First while assuming that the errors are iid.
  b) Again while allowing for heteroskedasticity-robust standard errors
  c) Lastly,  allow the errors to be correlated within individuals over time by clustering

Part 2:
1) Similar setup to part 1, but instead of having treatment be randomly assigned, it will be based on the outcome that is observed in 
period 6 (i.e., treatment is assigned to all individuals with outcomes below the sample median in this period)
2) Run 500 replications with a panel of 200 individuals
3) Retrieve the estimated treatment effect, its standard error estimate clustered on the individual, and whether the true effect is 
rejected at the five-percent level

Part 3: 
1) Repeat the simulation in part 2 but add to the regression model an indicator variable for being “one period before treated” (i.e.,
a variable that takes a one for the treatment group in period 6)
2) Retrieve the estimated treatment effect, its standard error estimate clustered on the individual, and whether the true effect is 
rejected at the five-percent level

Part 4:
1) Repeat part 2 but control for the outcome in period 6.
2) Retrieve the estimated treatment effect, its standard error estimate clustered on the individual, and whether the true effect is 
rejected at the five-percent level
