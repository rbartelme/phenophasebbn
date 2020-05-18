library(parallel)
library(bnlearn)
library(tensorflow)
library(tidyverse)
#================================================================
# 1.) Setup parallel and dataset importation
#================================================================
# setup parallel cluster config 
# (from bnlearn example: https://www.bnlearn.com/examples/pkg-parallel/)
# number of cores = 2, but 48 available, up this
cl = makeCluster(48)

#test cluster config
#rand = clusterEvalQ(cl, runif(10))
#cor(rand[[1]], rand[[2]])

#set seed for the whole cluster
clusterSetRNGStream(cl, 42)

#read in season 4 data
s4test<-read.table(file= "~/s4combined.txt", header = TRUE, sep = "\t", fill = TRUE)

#check colnames
#colnames(s4test)

#make a vector of colnames to remove; lodging_present has no values, drop it
data2cut<-c("sitename", "date", "treatment", "trait_description", "method_name", "units",
  "year", "station_number", "surface_temperature", "lodging_present")

#subset data with columns removed
s4clean<-as.data.frame(s4test[, !(colnames(s4test) %in% data2cut)])

#list colnames from s4 cleaned data
#colnames(s4clean)

#make dummy vars for cultivar, with a data frame of character/numeric values
cultivar_numeric<-as.data.frame(cbind(as.character(unique(s4clean$cultivar)),as.numeric(unique(s4clean$cultivar))))

#make colnames match
names(cultivar_numeric)<-c("cultivar", "num_cultivar")

#tibble conversion
cultivar_numeric<-as_tibble(cultivar_numeric)
s4clean<-as_tibble(s4clean)

#join/drop columns for cultivar names
s4_bnready<-left_join(s4clean, cultivar_numeric, by = 'cultivar') %>% select(-cultivar)
#sanity check
# names(s4_bnready)

#convert to dataframe
s4_bnIN <- as.data.frame(s4_bnready)
#convert everything to a factor for bnlearn interoperability
s4_bnIN[] <- lapply(s4_bnIN, as.factor)
#================================================================
# 2.) Structure Learning (DAG building)
#================================================================

#impute values for missing data in network with min-max hill-climbing, and impute
# add a list of parameters for 
net_sem = structural.em(s4_bnIN, maximize = "hc", maximize.args = list(), fit = "mle", fit.args = list(), impute = , 
                        impute.args = list())

#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================



#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================


