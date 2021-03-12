#!/usr/bin/env python3

# =================================================#
# Python3 refactored bayesian belief network model #
# =================================================#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# 1. Setup for bnlearn and import data #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

#load packages
import bnlearn as bn
import pandas as pd
import numpy as np
import sklearn as sk

#specify input data

df = pd.read_csv('~/path/to/input/file', sep='\t')

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# 2. Graph Structure Learning #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# "white list" connections, a priori links between data

# make an empty DAG

# Hill Climb Search for Graph Structure
model_hc_bic = bn.structure_learning.fit(df, methodtype='hc', scoretype='bic')

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# 3. Parallel parameter Learning (fit data to DAG) #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

#fit data to graph with parallel processing
DAG = bnlearn.parameter_learning.fit(DAG, df, methodtype='bayes')

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# 4. Parallel Cross Validation of Model  #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# need to sync k-folds between bnlearn and sklearn
