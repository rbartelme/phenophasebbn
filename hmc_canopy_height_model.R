library(tidyverse)
library(tidybayes)
library(rstan)
library(brms)
#set seed for R's random sample
set.seed(5)
# read in season 6 wide format dataframe
season6 <- read.table(file = "~/phenophasebbn/season6_combined", sep = "\t", header = TRUE,
           stringsAsFactors = FALSE)

#randomly sample 10 cultivars from the season for testing model
s6_cultivars <- sample(unique(season6$cultivar), size = 10)

#subset season6 dataframe by 10 randomly selected cultivars
s6_subset <- season6[season6$cultivar %in% s6_cultivars,]
