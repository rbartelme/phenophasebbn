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
#cultivar_numeric<-as.data.frame(cbind(as.character(unique(s4clean$cultivar)),as.numeric(unique(s4clean$cultivar))))

#make colnames match
#names(cultivar_numeric)<-c("cultivar", "num_cultivar")

#tibble conversion
#cultivar_numeric<-as_tibble(cultivar_numeric)
#s4clean<-as_tibble(s4clean)

#join/drop columns for cultivar names
#s4_bnready<-left_join(s4clean, cultivar_numeric, by = 'cultivar') %>% select(-cultivar)

#convert to dataframe
#s4_bnIN <- as.data.frame(s4_bnready)

#convert everything in data frame to a factor for bnlearn interoperability
s4clean[] <- lapply(s4clean, as.factor)

#s4_bnIN[] <- lapply(s4_bnIN, as.factor)

#================================================================
# 2a.) Define Structure (Heuristical DAG building)
#================================================================
#make an empty DAG
s4manDAG <- empty.graph(data2include)

#begin to encode edges and directions

#================================================================
# 2b.) Structure Learning (algorithmically build DAG)
#================================================================

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Start building blacklist matrix for derived data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# wind weather data
wind_mat<-t(combn(grep("*wind_*", colnames(s4clean), value = TRUE), m = 2))

# relative humidity
hum_mat <- t(combn(grep("rh_*", colnames(s4clean), value = TRUE), m = 2))

# air temperature
air_mat <- t(combn(grep("*air_*", colnames(s4clean), value = TRUE), m = 2))

#blacklist derived data in matrix
bl <- rbind(wind_mat, hum_mat, air_mat)
#add colnames recognized by bnlearn
colnames(bl) <- c("from", "to")

#whitelist a priori links
wl <- t(as.matrix(combn(c("daily_gdd", "canopy_height", "cultivar", "column", "range"),  m= 2 )))
#add colnames to wl
colnames(wl) <- c("from", "to")

#make an empty graph with wl & bl
s4learnDAG <- empty.graph(data2include)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Structure Learning Algorithms       #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# structure learning was running so rapidly because all commands lack restrict and maximize args
s4_tabu <- tabu(s4clean, whitelist = wl, blacklist = bl, tabu = 15, max.iter = 1000)
plot(s4_tabu)
#rsmax2
# a general implementation of the sparse candidate algorithm
# s4_rsmax2 <- rsmax2(s4_bnIN, blacklist = bl, whitelist = wl, restrict = "si.hiton.pc",  maximize = "hc", debug = TRUE)
s4_rsmax2 <- rsmax2(s4_bnIN, blacklist = bl, whitelist = wl, restrict = "si.hiton.pc", maximize = "tabu", test = "zf", alpha = 0.01, score = "bic-g", debug = TRUE)
plot(s4_rsmax2)
 
#mmhc
# a general implementation of min-max hill climbing

s4_mmhc <- mmhc(s4_bnIN, blacklist = bl, whitelist = wl, debug = TRUE)

plot(s4_mmhc)

#h2pc
#
s4_h2pc <- h2pc(s4_bnIN, blacklist = bl, whitelist = wl, debug = TRUE)

plot(s4_h2pc)

#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================



#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================
