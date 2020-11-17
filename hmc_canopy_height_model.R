library(tidyverse)
library(tidybayes)
library(rstan)
library(brms)
#set seed for R's random sample
set.seed(5)
# read in season 6 wide format dataframe
season6 <- na.omit(read.table(file = "~/phenophasebbn/season6_combined", sep = "\t", header = TRUE,
           stringsAsFactors = FALSE))

#randomly sample 1 cultivar from the season for testing model
s6_cultivars <- sample(unique(season6$cultivar), size = 1)

#subset season6 dataframe by 10 randomly selected cultivars
s6_subset <- season6[season6$cultivar %in% s6_cultivars,
                     colnames(season6) %in% c("sitename", "gdd", "canopy_height", "cultivar", "date")]
s6_subset <- s6_subset[order(as.Date(s6_subset$date), s6_subset$sitename),]
#setup for brms

#specify priors for sorghum growth curves and variable assignments
# prior requires a distribution, nlpar is the variable name
# c is the max height
# b is the growth rate
sorg_priors <- prior(normal(10, 5), nlpar = "a") +
  prior(normal(1, 0.5), nlpar = "b") +
  prior(normal(350,50), nlpar = "c") 

# specify the non-linear formula inside the fit function
fit1 <- brm(bf(canopy_height ~ c / (1 + exp(a + b * gdd)), 
               a + b + c ~ 1, nl = TRUE),
            data = s6_subset, prior = sorg_priors)

summary(fit1)


# storing the summary as a list of tables, one can extract the estimated values
# for a, b, and c sorg_fit_sum$fixed[,1]
#make dataframe to populate with a, b, c, and esimated inflection point output
# (c - a)/2
# would equivalently be something like:
# (fit1_summary$fixed[3,1]-fit1_summary$fixed[1,1])/2

# for loop for cultivars

