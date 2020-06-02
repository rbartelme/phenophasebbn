#load libraries
library(dplyr)
library(tidyr)

#Ran on the Rockerverse Container on CyVerse VICE 05-08-2020

#read in season4 trait data tall format
season4tall<-read.csv(file="~/phenophasebbn/season_4_tall_2020-05-08T203345.csv")

#convert to tibble
season4tall <- as_tibble(season4tall)

#make wide format
s4wide<- season4tall %>% mutate(row = row_number()) %>% pivot_wider(id_cols = c(row,lat,lon,date,range,column,cultivar), names_from = trait, values_from = value) %>%
  select(-row)

# ================================================================
# Further data Cleaning Starts Here
# ================================================================


# ================================================================
# 1) cut traits and environmental variables 
# ================================================================

#make a vector of colnames to remove; lodging_present has no values, drop it
data2cut<-c("sitename", "treatment", "trait_description", "method_name", "units",
            "year", "station_number", "surface_temperature", "lodging_present")

#Note: future network versions should include time in a dynamic BBN

#subset data with columns removed
s4_df<-as.data.frame(s4wide[, !(colnames(s4wide) %in% data2cut)])

# ================================================================
# 2) filter by cultivars in all data sets (including genomic)
# ================================================================
all_cult <- read_csv(file = "~/phenophasebbn/cultivar_look_up_2020-05-22.csv")

# convert to dataframe
cult_df <- as.data.frame(all_cult)

# first column is a character vector of all cultivars present across all seasons 
# (0 = not in season, 1 = in season; therefore rowsum = 4 is in all)
cultivars4net <- cult_df[rowSums(cult_df[,2:5])==4,1]

#filter season4 dataset by cultivars in all datasets
s4filtered<-as.data.frame(s4_df[s4_df$cultivar %in% cultivars4net,])

#remove all na canopy heights
s4_Df2<-s4filtered[!is.na(s4filtered$canopy_height),]

#convert season 4 dataframe to tibble
s4_tib<-as_tibble(s4_Df2)

# ================================================================
# 3) Join with weather data
# ================================================================

#read in weather data
season4weather<-read.csv("~/phenophasebbn/season_4_weather_gdd2020-05-08T203153.csv")

#left join weather and 
s4combined<-as.data.frame(left_join(s4_tib, season4weather, by="date"))


#write out tsv file
write.table(s4combined, file="~/phenophasebbn/s4combined.txt", quote = FALSE, sep = "\t")

#DEPRECATED: used iRODS iput to move this script, and its output to ../season4_bninput
#Input now resides in the github repo

