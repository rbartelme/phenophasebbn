library(parallel)
library(bnlearn)
library(tidyverse)

#================================================================
# 1.) Setup parallel and dataset importation
#================================================================
# setup parallel cluster config
# 48 cores
cl = makeCluster(16)
#set seed for the whole cluster
clusterSetRNGStream(cl, 42)

# read in season 4 data
s4test<-read.table(file= "~/phenophasebbn/s4combined.txt", header = TRUE, sep = "\t", fill = TRUE)

# test data
data2include<-c("cultivar", "canopy_height",  "vpd_mean", "daily_gdd", "air_temp_mean", "rh_mean",
                "precip_total")

# ==========================================================================================
#Improvement: future network versions should include time in a dynamic BBN
# ==========================================================================================

#subset data by variables to include
s4clean<-as.data.frame(s4test[, colnames(s4test) %in% data2include])

#convert everything in data frame to a factor for bnlearn interoperability
s4clean[] <- lapply(s4clean, as.factor)

#================================================================
# 2a.) Define Structure (Heuristical DAG building)
#================================================================
#make an empty DAG
s4manDAG <- empty.graph(data2include)

#begin to encode edges and directions
edges = matrix(c("cultivar", "canopy_height", "daily_gdd", "canopy_height", "precip_total", "canopy_height","vpd_mean","canopy_height","rh_mean", "canopy_height", "air_temp_mean","canopy_height"),
               ncol = 2, byrow = TRUE,
               dimnames = list(NULL, c("from", "to")))

#manually assign edges to empty graph
arcs(s4manDAG) = edges
plot(s4manDAG)
#================================================================
# 2b.) Structure Learning (algorithmically build DAG)
#================================================================

# exclude derived data through "black list"
bl <- matrix(c("rh_mean", "vpd_mean", "air_temp_mean", "vpd_mean"),
             ncol = 2, byrow = TRUE,
             dimnames = list(NULL, c("from", "to")))

 
# include a priori links through "white list"
wl <- matrix(c("cultivar", "canopy_height", "daily_gdd", "canopy_height", "precip_total","canopy_height"),
             ncol = 2, byrow = TRUE,
             dimnames = list(NULL, c("from", "to")))

#make an empty graph with wl & bl
s4learnDAG <- empty.graph(data2include)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Structure Learning Algorithms       #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# hill climb search *needs improvement
s4_hc <- hc(s4clean, whitelist = wl, blacklist = bl)
plot(s4_hc)


# tabu greedy search
s4_tabu <- tabu(s4clean, whitelist = wl, blacklist = bl, tabu = 10, max.tabu = 5)
plot(s4_tabu)

#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================

#define a function to fit networks for season4 data with the same parameters
fit_net<-function(bn){
  bn.fit(x=bn, data = s4clean, cluster = cl, method = "mle", keep.fitted = TRUE)
}

#fit data to manual graph
s4_man_fit <- fit_net(s4manDAG)
#Throws error:
# Error in checkForRemoteErrors(val) : 
# one node produced an error: attempting to create a table with more than INT_MAX cells. 

#fit data to HC graph
s4_hc_fit <- fit_net(s4_hc)

#bayesian information criterion of the fit
BIC(s4_hc_fit, s4clean)

#fit data to tabu graph
s4_tabu_fit<-fit_net(s4_tabu)

#BIC for the graph fit
BIC(s4_tabu_fit, s4clean)


#======= Not Working: Functional Programming Solution to multiple learning algo's ==========#

#make a list of DAG's
s4_dag_list<-list(s4manDAG,s4_hc,s4_tabu)

#use map from purrr to operate the bn.fit function over the list of DAG's
  # output: a list of fitted BN's
s4_fitted_list<-map(s4_dag_list, fit_net)
#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================
