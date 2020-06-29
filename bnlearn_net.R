library(parallel)
library(bnlearn)
library(tidyverse)
library(Rgraphviz)

#================================================================
# 1.) Setup parallel and dataset importation
#================================================================
# set seed for r env
set.seed(42)
# setup parallel cluster config
# 48 cores
cl <- makeCluster(16)
#set seed for the whole cluster
clusterSetRNGStream(cl, 42)

# read in season 4 data
s4test <- read.table(file = "~/phenophasebbn/s4combined.txt",
      header = TRUE, sep = "\t", fill = TRUE)
# read in season 6 data
s6 <- read.table(file = "~/phenophasebbn/s6combined.txt",
      header = TRUE, sep = "\t", fill = TRUE)

#Note changed from daily GDD to GDD June 26 2020

# test data
data2include <- c("cultivar", "canopy_height", "vpd_mean", "gdd",
        "air_temp_mean", "rh_mean", "precip_total")

# ========================================================================
#Improvement: future network versions should include time in a dynamic BBN
# ========================================================================

#subset data by variables to include
s4clean <- as.data.frame(s4test[, colnames(s4test) %in% data2include])

s6clean <- na.omit(as.data.frame(s6[, colnames(s6) %in% data2include]))

#convert everything in data frame to a factor for bnlearn interoperability
s4clean[] <- lapply(s4clean, as.factor)
s6clean[] <- lapply(s6clean, as.factor)

#================================================================
# 2.) Structure Learning (algorithmically build DAG)
#================================================================

# exclude derived data through "black list"
bl <- matrix(c("rh_mean", "vpd_mean", "air_temp_mean", "vpd_mean"),
             ncol = 2, byrow = TRUE,
             dimnames = list(NULL, c("from", "to")))


# include a priori links through "white list"
wl <- matrix(c("cultivar", "canopy_height", "gdd", "canopy_height",
              "precip_total", "canopy_height"),
             ncol = 2, byrow = TRUE,
             dimnames = list(NULL, c("from", "to")))

#make an empty graph with wl & bl
sorg_dag <- empty.graph(data2include)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Structure Learning Algorithms       #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#All start with an empty graph


# hill climb search
s4_hc <- hc(s4clean, start = sorg_dag, whitelist = wl, blacklist = bl)
plot(s4_hc)

s6_hc <- hc(s6clean, start = sorg_dag, whitelist = wl, blacklist = bl)
plot(s6_hc)


s6_4_seed <- hc(s6clean, start = s4_hc, whitelist = wl, blacklist = bl)

plot(s6_4_seed) #same as s4_hc result

s4_6_seed <- hc(s4clean, start = s6_hc, whitelist = wl, blacklist = bl)

plot(s4_6_seed) #same as s6_hc result

hamming(s6_4_seed, s4_6_seed)

# tabu greedy search
s4_tabu <- tabu(s4clean, start = sorgDAG, whitelist = wl,
      blacklist = bl, tabu = 10, max.tabu = 5)
plot(s4_tabu)

s6_tabu <- tabu(s6clean, start = sorgDAG, whitelist = wl,
      blacklist = bl, tabu = 10, max.tabu = 5)
plot(s6_tabu)
#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================

s4_hc_fit2 <- bn.fit(s4_hc, data = s4clean, cluster = cl,
  method = "mle", keep.fitted = TRUE)

s6_hc_fit <- bn.fit(s6_hc, data = s6clean,  cluster = cl,
  method = "mle", keep.fitted = TRUE)

#bayesian information criterion of the fit
BIC(s4_hc_fit2, s4clean)

#Original Result: -88021526
#New GDD Result: -97605837

BIC(s6_hc_fit, s6clean)
#-61928662

# hamming distance of HC learned networks across seasons
# set "true" network to be the one with the lowest BIC fit for its dataframe
hamming(s6_hc, s4_hc) # distance: 6



#fit data to tabu graph
s4_tabu_fit2 <- bn.fit(s4_tabu, data = s4clean, cluster = cl,
          method = "mle", keep.fitted = TRUE)

s6_tabu_fit <- bn.fit(s6_tabu, data = s6clean, cluster = cl,
          method = "mle", keep.fitted = TRUE)

#BIC for the graph fit
BIC(s4_tabu_fit2, s4clean)
#Old Result: -29592185
#New GDD Result: -97605837

BIC(s6_tabu_fit, s6clean)
# -61928662

# hamming distance of tabu learned networks across seasons
# set "true" network to be the one with the lowest BIC fit for its dataframe
hamming(s6_tabu, s4_tabu) # distance: 6


# June 24: BIC are equal between hc and tabu,
  # cluster seed is the same, but fit function throws error
  # removed FP fit solution, function deprecated
  # June 26: no fit function error

#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================

# Pseudocoded as of June 26 2020,
  #need to discuss best strategy for implementation
#default is log-likelihood loss,
  # k=10, runs is the number of times the k-fold cross validation will run

# s4 BIC C-V hc
s4_cv_hc_bic <- bn.cv(s4clean, bn = "hc", runs = 100, cluster = cl,
          algorithm.args = list(score = "bic"))

s4_cv_tabu_bic <- bn.cv(s4clean, bn = "tabu", runs = 100, cluster = cl,
          algorithm.args = list(score = "bic"))

# s6 BIC C-V
s6_cv_hc_bic <- bn.cv(s6clean, bn = "hc", runs = 100, cluster = cl,
          algorithm.args = list(score = "bic"))

s6_cv_tabu_bic <- bn.cv(s6clean, bn = "tabu", runs = 100, cluster = cl,
          algorithm.args = list(score = "bic"))


# compare BIC and BDe scores with box plots
plot(s4_cv_hc_bic, s4_cv_tabu_bic, s6_cv_hc_bic,
    s6_cv_tabu_bic, xlab = c("S4 HC", "S4 Tabu", "S6 HC", "S6 Tabu"))

# Notes: Possibly drop VPD?
# Use season 4 graph to start with season 6 hc algorithm??
# could also subset by "control treatment" and test vs. the Sorghum BAP
# season 4 had a drought treatment, "unplanned experiment",
# August 1st was start of drought treatment
# VPD and GDD alone instead of including RH and AIR temp
# category: photoperiod sensitivity between cultivars
  # cellulosic (biomass), sweet (food), and grain?
  #
