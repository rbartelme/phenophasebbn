#load libraries
library(dplyr)
library(tidyr)

#Ran on the Rockerverse Container on CyVerse VICE 05-08-2020

#read in season4 trait data tall format
season4tall<-read.csv(file="~/season_4_tall_2020-05-08T203345.csv")

#convert to tibble
season4tall <- as_tibble(season4tall)

#make wide format
s4wide<- season4tall %>% mutate(row = row_number()) %>% pivot_wider(id_cols = c(row,lat,lon,date,range,column,cultivar), names_from = trait, values_from = value) %>%
  select(-row)


#read in weather data
season4weather<-read.csv("~/season_4_weather_gdd2020-05-08T203153.csv")

#left join weather and 
s4combined<-as.data.frame(left_join(s4wide, season4weather, by="date"))


#write out tsv file
write.table(s4combined, file="~/s4combined.txt", quote = FALSE, sep = "\t")

#used iRODS iput to move this script, and its output to ../season4_bninput

