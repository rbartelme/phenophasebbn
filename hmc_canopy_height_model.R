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
# sorg_priors <- prior(normal(10, 5), nlpar = "a") +
#   prior(normal(1, 0.5), nlpar = "b") +
#   prior(normal(350,50), nlpar = "c") 
# 
# # specify the non-linear formula inside the fit function
# fit1 <- brm(bf(canopy_height ~ c / (1 + exp(a + b * gdd)), 
#                a + b + c ~ 1, nl = TRUE),
#             data = s6_subset, prior = sorg_priors)
# 
# summary(fit1)
# 


#single cultivar debug
sorg_priors2 <- prior(gamma(2, 2), lb = 0.01, nlpar = "b") +
  prior(gamma(130, 0.35), lb = 300, nlpar = "c")

fit2 <- brm(bf(canopy_height ~ c / (1 + exp(b * gdd)),
          b + c ~ 1, nl = TRUE),
          data = s6_subset, prior = sorg_priors2,
          control = list(adapt_delta = 0.99),
          cores = 4, thin = 5, iter = 20000, seed = 42)
#
summary(fit2)
# 


# storing the summary as a list of tables, one can extract the estimated values
# for a, b, and c sorg_fit_sum$fixed[,1]
#make dataframe to populate with b, c, and estimated inflection point (c/2) output
# c/2
# would equivalently be something like:
# (fit1_summary$fixed[3,1]-fit1_summary$fixed[1,1])/2


#make season6 dataframe into a list of data frames for each cultivar
s6_cultivar_list <- split(season6, season6$cultivar, drop = TRUE)

#hmc output for each cultivar
hmc_out <- data.frame(cultivar = character(),
                      est_growth_rate = numeric(), 
                      est_max_growth = numeric(),
                      measured_max_growth = numeric(),
                      sd_est_meas_max_growth = numeric(),
                      est_inflection_point = numeric(),
                      stringsAsFactors=FALSE) 

gen_sorg_priors <- prior(gamma(2, 2), lb = 0.01, nlpar = "b") +
  prior(gamma(130, 0.35), lb = 300, nlpar = "c")

for(i in 1:length(s6_cultivar_list)){
  hmc_out[i,1] <- names(s6_cultivar_list)[[i]] #store cultivar name
  #run brms for cultivar with generalized priors
  model_fit <- brm(bf(canopy_height ~ c / (1 + exp(b * gdd)),
            b + c ~ 1, nl = TRUE),
         data = s6_cultivar_list[[i]], prior = gen_sorg_priors,
         control = list(adapt_delta = 0.99),
         cores = 4, thin = 5, iter = 20000, seed = 42)
  model_fit_sum <- summary(model_fit) #get model fit summary
  hmc_out[i,2] <- model_fit_sum$fixed[1,1] #extract estimated growth rate
  hmc_out[i,3] <- model_fit_sum$fixed[2,1] #extract estimated height
  hmc_out[i,4] <- max(s6_cultivar_list[[i]]$canopy_height) #measured max height
  hmc_out[i,5] <- sd(hmc_out[i,3], hmc_out[i,4]) #sd of heights
  hmc_out[i,6] <- hmc_out[i,3]/2 #estimated inflection point 
}
