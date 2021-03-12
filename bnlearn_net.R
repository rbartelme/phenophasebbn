library(parallel)
library(bnlearn)
library(tidyverse)
library(Rgraphviz)

#================================================================
# 1.) Setup parallel and dataset importation
#================================================================
# set seed for r env
set.seed(5)
# setup parallel cluster config
# 16 cores
cl <- makeCluster(16)

#set seed for the whole cluster
clusterSetRNGStream(cl, 42)

# read in tabular data
sorg_tab <- read.table(file = "~/phenophasebbn/bn_input.txt",
      header = TRUE, sep = "\t", fill = TRUE)
# ========================================================
# debug missing weather data
# sorg_nas <- which(is.na(sorg_tab), arr.ind=TRUE)
# sorg_fix <- sorg_tab[sorg_nas[,1],]
# sorg_dates2fix <- as.data.frame(unique(sorg_fix[,c(1,4)]))
# ========================================================

#Remove NA values, early/late dates have NA's
sorg_tab <- as.data.frame(na.omit(sorg_tab))

#convert date from factor to date class
sorg_tab$date <- as.Date(sorg_tab$date)

#convert to just year
sorg_tab$date <- format(sorg_tab$date, "%Y")

#rename date to year
names(sorg_tab)[names(sorg_tab) == "date"] <- "year"

#convert year to numeric
sorg_tab$year <- as.numeric(sorg_tab$year)

#convert everything in data frame to a factor for bnlearn interoperability
sorg_tab[] <- lapply(sorg_tab, as.factor)

#================================================================
# 2.) Structure Learning (algorithmically build DAG)
#================================================================

# include a priori links through "white list"
wl <- matrix(c("cultivar", "canopy_height", "gdd", "canopy_height",
              "precip_cumulative", "canopy_height"),
             ncol = 2, byrow = TRUE,
             dimnames = list(NULL, c("from", "to")))

#make an empty graph with wl & bl
sorg_dag <- empty.graph(colnames(sorg_tab))

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Structure Learning Algorithms       #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# starts with an empty graph: sorg_dag


# hill climb search for combined data graph structure
sorg_hc <- hc(sorg_tab, start = sorg_dag, whitelist = wl)
plot(sorg_hc)


#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================

sorg_fit <- bn.fit(sorg_hc, data = s4clean, cluster = cl,
  method = "mle", keep.fitted = TRUE)

#bayesian information criterion of the fit
BIC(sorg_fit, sorg_tab)

# Old BIC results with just season 4 data
# and the following features:
# "cultivar", "canopy_height", "vpd_mean", "gdd", "precip_total"
# Original Result: -88021526
# June 2020, New GDD Result: -97605837
#================================================================
# September 2020, New features BIC Result:


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
plot(s4_cv_hc_bic, s4_cv_tabu_bic, xlab = c("S4 HC", "S4 Tabu"))

# Notes: Possibly drop VPD?
# Use season 4 graph to start with season 6 hc algorithm??
# could also subset by "control treatment" and test vs. the Sorghum BAP
# season 4 had a drought treatment, "unplanned experiment",
# August 1st was start of drought treatment
# VPD and GDD alone instead of including RH and AIR temp
# category: photoperiod sensitivity between cultivars
  # cellulosic (biomass), sweet (food), and grain?
  #
