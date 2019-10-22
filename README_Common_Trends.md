# Difference_in_Differences (DiD)

Here we will look at the common trends assumption in DiD.

Problem: 
We want to examine how the estimate of our parameter of interest will be biased when the treatment group and control group have different trends

We will estimate the DiD model: 

Yit = β0 + β1Treaat_i + β2Post_t + β3Treat_i * Post_t + e_it

such that
T_i is an indicator variable taking the value 1 if individual i is in the treatment group and zero otherwise 
Post_t is an indicator variable taking the value 1 if the time period is from the post-treatment period
e ∼ N(0, 1)  
β3 is the treatment effect, or how outcomes in the post period for the treatment group diverge from what is expected based on the their outcomes in pre period and based on the passage of time (parameter of interest)

1) Create a panel of 300 individuals (i.e., i = 1, . . . , 300) over ten periods (i.e., i = 1, . . . , 10) 
2) Divide the individuals equally into control and treatment groups where treatment occurs between periods 5 and 6 
3) Assume β0 = 1, β1 = 1.5, β2 = 2, β3 = 3.
4) Regress the model
5) Hypothesis testing
6) Introduce a trend to the treatment group over -.6(.2).6 (i.e., run 7 simulations of 500 replications each) 
7) Summarize results
