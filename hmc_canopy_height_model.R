library(tidyverse)
library(tidybayes)
library(rstan)
library(brms)
#set seed for R's random sample
set.seed(5)
# read in season 6 wide format dataframe
season6 <- na.omit(read.table(file = "~/phenophasebbn/season6_combined", sep = "\t", header = TRUE,
           stringsAsFactors = FALSE))

#randomly sample 10 cultivars from the season for testing model
s6_cultivars <- sample(unique(season6$cultivar), size = 10)

#subset season6 dataframe by 10 randomly selected cultivars
s6_subset <- season6[season6$cultivar %in% s6_cultivars,
                     colnames(season6) %in% c("sitename", "gdd", "canopy_height", "cultivar", "date")]
s6_subset <- s6_subset[order(as.Date(s6_subset$date), s6_subset$sitename),]
#setup for brm
#rstan_options(auto_write = TRUE)
#test_brm <- brm(formula = canopy_height ~ gdd + (sitename|cultivar), family = lognormal(), data = s6_subset,
#                seed = 42, warmup = 1000, iter = 2000, chains = 4, cores = 4, 
#                control = list(adapt_delta = 0.95), save_model = 'season6.stan')

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#NOTES: 
# general form for brm is:
# response ~ pterms + (gterms | group)
# where p are "population level terms, in this case, gdd.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# however this is a complex hierarchical non-linear model, so best get to functional modeling:
# the model for canopy height as a logistic growth function of gdd is:
# canopy_height ~ c / (1 + exp(a + b * x)
# x ~ gdd + (1|sitename|cultivar)
# a ~ (1|sitename|cultivar)
# b ~ (1|sitename|cultivar)
# c ~ (1|sitename|cultivar)
# gdd has a monotonic effect with regard to canopy_height

ggplot(data = s6_subset, mapping = aes(x = gdd, y = canopy_height, colour = sitename))+geom_point()
