library(parallel)
library(bnlearn)
library(tidyverse)

#================================================================
# 1.) Setup parallel and dataset importation
#================================================================
# setup parallel cluster config
# 48 cores
cl = makeCluster(48)
#set seed for the whole cluster
clusterSetRNGStream(cl, 42)

# read in season 4 data
s4test<-read.table(file= "~/phenophasebbn/s4combined.txt", header = TRUE, sep = "\t", fill = TRUE)

# read in csv of cultivars across all studies
 #NOTE: had to write in "cultivar" manually in first columnm, throws error with column names
all_cult <- read_csv(file = "~/phenophasebbn/cultivar_look_up_2020-05-22.csv")

# convert to dataframe
cult_df <- as.data.frame(all_cult)

# character vector of all cultivars present across all seasons 
  # (0 = not in season, 1 = in season; therefore rowsum = 4 is in all)
cultivars4net <- cult_df[rowSums(cult_df[,2:5])==4,1]

#make a vector of colnames to remove; lodging_present has no values, drop it
data2cut<-c("sitename", "date", "treatment", "trait_description", "method_name", "units",
  "year", "station_number", "surface_temperature", "lodging_present")
  
#Improvement: future network versions should include time in a dynamic BBN
  
#Note: alternatively could filter by data that are being used.

#subset data with columns removed and by cultivars present in all datasets (UNTESTED)
s4clean<-as.data.frame(s4test[s4test$cultivar %in% cultivars4net, !(colnames(s4test) %in% data2cut)])



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

#impute values for missing data in network with min-max hill-climbing, and impute
# add a list of parameters for
net_sem = structural.em(s4_bnIN, maximize = "hc", maximize.args = list("cluster" = cl), fit = "mle", fit.args = list("cluster" = cl))

#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================



#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================
