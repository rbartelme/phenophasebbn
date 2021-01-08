library(tidyverse)
library(tidybayes)
library(rstan)
library(brms)
library(shinystan)
# To avoid recompilation of unchanged Stan programs, we recommend calling
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

#set seed for R's random sample
set.seed(5)
# read in season 6 wide format dataframe
season6 <- na.omit(read.table(file = "~/phenophasebbn/season6_combined.txt", sep = "\t", header = TRUE,
           stringsAsFactors = FALSE))


#randomly sample 1 cultivar from the season for testing model
s6_cultivars <- sample(unique(season6$cultivar), size = 1)

#subset season6 dataframe by 10 randomly selected cultivars
s6_subset <- season6 %>%  filter(cultivar %in% s6_cultivars) %>% 
  select(sitename, gdd, canopy_height, cultivar, date) %>% 
  arrange(date)

ggplot(data = s6_subset, aes(gdd, canopy_height, color = cultivar, group = sitename)) +
  geom_point() +
  geom_line()


# s6_subset <- s6_subset[order(as.Date(s6_subset$date), s6_subset$sitename),]
# s6_subset_sites <- split(s6_subset, s6_subset$sitename, drop = TRUE)
# 
# canopy_summary <- vector(mode = "list", length = length(s6_subset_sites))
# date_fixed <- vector(mode = "list", length = length(s6_subset_sites))
# names(canopy_summary) <- names(s6_subset_sites)
# names(date_fixed) <- names(s6_subset_sites)
# 
# for(i in 1:length(s6_subset_sites)){
# date_fixed[[i]] <- distinct(s6_subset_sites[[i]], date, .keep_all = TRUE)
# canopy_summary[[i]] <- summary(date_fixed[[i]]$canopy_height)
# }
# #(as.numeric(canopy_summary[[1]][5] - as.numeric(canopy_summary[[1]][2]))/
# s6_subset_sites[[1]]   

# #setup for brms

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

#need to adjust random start, step size, and step jitter

#single cultivar debug
sorg_priors2 <- prior(normal(10, 2),  lb = 0, class = 'b',  nlpar = "a") +
  prior(gamma(2, 2), lb = 0.01, nlpar = "b") +
  prior(gamma(130, 0.35), lb = 300, nlpar = "c")


fit3 <- brm(bf(canopy_height ~ c / (1 + exp(a + b * gdd)), 
               b + c ~ (1|gr(sitename, cor = FALSE)),
               a ~ 1,
               nl = TRUE,
               center = FALSE),
            data = s6_subset, prior = sorg_priors2,
            control = list(adapt_delta = 0.8, 
                           stepsize = 0.1,
                           max_treedepth = 20), 
            chains = 7,
            cores = 7,
            iter = 1000, seed = 55)

saveRDS(fit3, file = "~/phenophasebbn/fit3.rds")
my_sso <- launch_shinystan(fit3)

# 
# fit2 <- brm(bf(canopy_height ~ c / (1 + exp(b * gdd)),
#           b + c ~ 1, nl = TRUE),
#           data = s6_subset, prior = sorg_priors2,
#           control = list(adapt_delta = 0.99),
#           cores = 4, thin = 5, iter = 20000, seed = 42)
# #
# summary(fit2)
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
N <- length(s6_cultivar_list)
hmc_out <- data.frame(cultivar = character(N),
                      est_growth_rate = numeric(N), 
                      est_max_growth = numeric(N),
                      measured_max_growth = numeric(N),
                      stringsAsFactors=FALSE) 
gen_sorg_priors <- prior(gamma(2, 2.5), lb = 0.01, nlpar = "b") +
  prior(gamma(130, 0.35), lb = 250, nlpar = "c")

find_growth_params <- function(li, pref){for(i in 1:length(li)){
  hmc_out[i,1] <- names(li)[[i]] #store cultivar name
  stanout <- paste0(pref, names(li)[[i]]) #name stan file output
  #run brms for cultivar with generalized priors
  model_fit <- brm(bf(canopy_height ~ c / (1 + exp(b * gdd)),
            b + c ~ 1, nl = TRUE),
         data = li[[i]], prior = gen_sorg_priors,
         control = list(adapt_delta = 0.99),
         cores = 4, thin = 5, iter = 20000, seed = 42,
         save_model = stanout)
  model_fit_sum <- summary(model_fit) #get model fit summary
  hmc_out[i,2] <- model_fit_sum$fixed[1,1] #extract estimated growth rate
  hmc_out[i,3] <- model_fit_sum$fixed[2,1] #extract estimated height
  hmc_out[i,4] <- max(li[[i]]$canopy_height) #measured max height
  }
}
find_growth_params(s6_cultivar_list, "s6_")
