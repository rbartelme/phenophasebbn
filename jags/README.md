# *Sorghum bicolor bicolor* parameters from Bayesian logistic regression

The dense timeseries of canopy height from the gantry at Maricopa Agricultural Center capture the trajectory of plant growth, but result in too many variables to be used in other analyses. While simple summary statistics such as mean, max, and min can be easily calculated, they may not be the most biologically relevant and are subject to outliers. Therefore, we developed a cleaning algorithm to QA/QC the MAC canopy height data in `phenophasebbn/bnprocess_mac.R` and a set of scripts and functions to apply a Bayesian logistic regression to obtain height and growth parameters for each cultivar `phenophasebbn/jags/`. 

# QA/QC


Additionally, a small fraction of the automated measurements are erroneous