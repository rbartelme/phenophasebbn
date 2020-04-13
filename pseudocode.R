# set seed
set.seed(1234)

# load libraries
library(parallel)
library(bnlearn)
library(caret)


#It is highly likely that learning and fitting need to be parallelized
  # 04-13-20: added in parallelization points within pseudocode

# load curated season 4 dataset as dataframe
season4 <- read.table("some_file.csv", header = TRUE, sep = ",")

# widen traits, keep dates/cultivars as a specific column

# one hot encode cultivar data dummyVars from caret package

# run hybrid hpc/hill climbing algorithm on the data
  # * parallelize task
season4_h2pc <- h2pc(season4, whitelist = NULL, blacklist = NULL, restrict.args = list(), maximize.args = list(), debug = FALSE)

# plot the results of h2pc as a DAG
  # suppress print, or export image as a diagnostic?
plot(season4_h2pc)

# Heuristic curation??
  # Optional step, could be fixed by removing derived data

# fit bbn model to the results of the learning algorithm
  # * parallelize task

fittedbbn <- bn.fit(season4_h2pc, data = season4)

# Write out UTF encoded text version of fitted network
  # this can be imported after running on HPC

#export bn.fit as string
fit_bbn_str <- modelstring(fittedbbn, debug = FALSE)

#export bn.net?? Underlying network structure.

# ==================================================
## Sandbox for extended features                  ##
# ==================================================

# Event querying for specific traits

# Extend to include NPN libraries??
