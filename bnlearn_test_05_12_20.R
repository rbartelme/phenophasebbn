library(parallel)
library(bnlearn)
library(tensorflow)
library(tidyverse)
#================================================================
# 1.) Setup parallel and dataset importation
#================================================================
# setup parallel cluster config 
# (from bnlearn example: https://www.bnlearn.com/examples/pkg-parallel/)
cl = makeCluster(2)

#test cluster config
#rand = clusterEvalQ(cl, runif(10))
#cor(rand[[1]], rand[[2]])

#set seed for the whole cluster
clusterSetRNGStream(cl, 42)

#read in season 4 data
s4test<-read.table(file= "~/s4combined.txt", header = TRUE, sep = "\t", fill = TRUE)

#check rownames
colnames(s4test)

#make a vector of colnames to remove
data2cut<-c("sitename", "date", "treatment", "trait_description", "method_name", "units",
  "year", "station_number", "surface_temperature")

#subset data with columns removed
s4clean<-as.data.frame(s4test[, !(colnames(s4test) %in% data2cut)])

#list colnames from s4 cleaned data
colnames(s4clean)

#make dummy vars for cultivar, with a data frame of character/numeric values
cultivar_numeric<-as.data.frame(cbind(as.character(unique(s4clean$cultivar)),as.numeric(unique(s4clean$cultivar))))

#make colnames match
names(cultivar_numeric)<-c("cultivar", "num_cultivar")

#tibble conversion
cultivar_numeric<-as_tibble(cultivar_numeric)
s4clean<-as_tibble(s4clean)

s4_bnready<-left_join(s4clean, cultivar_numeric, by = 'cultivar') %>% select(-cultivar)
names(s4_bnready)

s4_bnIN <- as.data.frame(s4_bnready)
#================================================================
# 2.) Parallel Structure Learning (DAG building)
#================================================================

#min-max hill climbing for structure learning
mmhc(x = s4_bnIN, cluster = cl)
#================================================================
# 3.) Parallel parameter learning (fitting data to DAG)
#================================================================



#================================================================
# 4.) Parallel cross-validation (validating fit of data to model)
#================================================================


