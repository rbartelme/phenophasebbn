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
#cultivar filtering moved to season4_bnprocess.R
# new output from bnprocess adds .x and .y to colnames?

s4test<-read.table(file= "~/phenophasebbn/s4combined.txt", header = TRUE, sep = "\t", fill = TRUE)
#clean up column names
colnames(s4test)<-gsub(".x$","",colnames(s4test))
colnames(s4test)<-gsub(".y$","",colnames(s4test))

#data to include
data2include<-c("range", "column", "cultivar", "canopy_height", "flag_leaf_emergence_time", "vpd_mean", "daily_gdd","wind_speed_mean", "wind_vector_magnitude",
                "wind_vector_direction", "wind_direction_std", "max_wind_speed", "air_temp_max", "air_temp_min", "air_temp_mean", "rh_max", "rh_min", "rh_mean",
                "precip_total")

# ==========================================================================================
#Improvement: future network versions should include time in a dynamic BBN
# ==========================================================================================

#subset data by variables to include
s4clean<-as.data.frame(s4test[, colnames(s4test) %in% data2include])

#make dummy vars for cultivar, with a data frame of character/numeric values
cultivar_numeric<-as.data.frame(cbind(as.character(unique(s4clean$cultivar)),as.numeric(unique(s4clean$cultivar))))

#make colnames match
names(cultivar_numeric)<-c("cultivar", "num_cultivar")

#tibble conversion
cultivar_numeric<-as_tibble(cultivar_numeric)
s4clean<-as_tibble(s4clean)

#join/drop columns for cultivar names
s4_bnready<-left_join(s4clean, cultivar_numeric, by = 'cultivar') %>% select(-cultivar)

#convert to dataframe
s4_bnIN <- as.data.frame(s4_bnready)

#convert everything in data frame to a factor for bnlearn interoperability
s4_bnIN[] <- lapply(s4_bnIN, as.factor)
summary(s4_bnIN$flag_leaf_emergence_time)
#================================================================
# 2.) Structure Learning (DAG building)
#================================================================

#impute values for missing data in network with min-max hill-climbing, and impute
# add a list of parameters for
net_sem = structural.em(s4_bnIN, maximize = "hc", maximize.args = list("cluster" = cl), fit = "mle", debug = TRUE)
plot(net_sem)
#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================



#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================
