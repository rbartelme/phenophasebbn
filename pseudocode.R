# set seed
set.seed(1234)

# load libraries
library(bnlearn)

# load curated season 4 dataset as dataframe
season4 <- read.table("some_file.csv", header = TRUE, sep = ",")

# widen traits, keep dates/cultivars as a specific column

# one hot encode cultivar data dummyVars from caret package

# run hybrid hpc/hill climbing algorithm on the data
season4_h2pc <- h2pc(season4, whitelist = NULL, blacklist = NULL, restrict.args = list(), maximize.args = list(), debug = FALSE)

# plot the results of h2pc as a DAG
plot(season4_h2pc)

# Heuristic curation??

# fit bbn model to the results of the learning algorithm

fittedbbn <- bn.fit(season4_h2pc, data = season4)

# Event querying for specific traits

# Extend to include NPN libraries??
