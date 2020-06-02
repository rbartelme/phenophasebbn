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


#data to include; excluding "flag_leaf_emergence_time", for this since NA's are appearing
data2include<-c("range", "column", "cultivar", "canopy_height",  "vpd_mean", "daily_gdd","wind_speed_mean", "wind_vector_magnitude",
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

#================================================================
# 2.) Structure Learning (DAG building)
#================================================================

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Start building blacklist matrix for derived data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# wind weather data
wind_mat<-t(combn(grep("*wind_*", colnames(s4_bnIN), value = TRUE), m = 2))

# relative humidity
hum_mat <- t(combn(grep("rh_*", colnames(s4_bnIN), value = TRUE), m = 2))

# air temperature
air_mat <- t(combn(grep("*air_*", colnames(s4_bnIN), value = TRUE), m = 2))

#blacklist derived data in matrix
bl <- rbind(wind_mat, hum_mat, air_mat) 
#add colnames recognized by bnlearn
colnames(bl) <- c("from", "to")

#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================



#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================
