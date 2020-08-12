#load libraries
library(tidyverse)

# add wget statements for tall format data

# read in CSV filepaths as list
data_path <- list("filepath1", "filepath2", "filepath3")

# use map from purrr to read in csv files
raw_data <- map(.x = data_path, .f = read.csv())

#convert to tibble
raw_data <- map(.x = raw_data, .f = as_tibble())

# wide format data function
first_pass <- function(i){
  j <- i %>%
    mutate(row = row_number()) %>%
    pivot_wider(id_cols = c(row, lat, lon, date,
                            range, column, cultivar, treatment),
                names_from = trait, values_from = value)   %>% 
    select(-row)
  return(j)
}

#make a list of wide format tibbles
wide_trait_data <- list()
wide_trait_data <- map(.x = raw_data, .f = first_pass)

# ================================================================
# 1) cut traits and environmental variables
# ================================================================

#make a vector of colnames to remove; lodging_present has no values, drop it
data2cut <- c("sitename", "treatment", "trait_description", "method_name",
              "units", "year", "station_number", "surface_temperature", "lodging_present")

#Note: future network versions should include time in a dynamic BBN
cut_data <- function(df){as.data.frame(df[, !(colnames(df) %in% data2cut)])}


# ================================================================
# 2) filter by cultivars in all data sets (including genomic)
# ================================================================
# read in cultivar lookup table
all_cult <- read.csv(file = "~/phenophasebbn/cultivar_look_up_2020-05-22.csv")

# convert to dataframe
cult_df <- as.data.frame(all_cult)

# first column is a character vector of all cultivars present across all seasons
# (0 = not in season, 1 = in season; therefore rowsum = 4 is in all)
# make character vector of all cultivars in all seasons
cultivars4net <- cult_df[rowSums(cult_df[, 2:5]) == 4, 1]

#define filter cultivar function
filter_cultivar <- function(df){as.data.frame(df[df$cultivar %in% cultivars4net, ])}


#filter season4 dataset by cultivars in all datasets
s4filtered <- as.data.frame(s4_df[s4_df$cultivar %in% cultivars4net, ])
s6filtered <- as.data.frame(s6_df[s6_df$cultivar %in% cultivars4net, ])
#remove all na canopy heights
s4_df2 <- s4filtered[!is.na(s4filtered$canopy_height), ]
s6_df2 <- s6filtered[!is.na(s6filtered$canopy_height), ]
#convert season 4 dataframe to tibble
s4_tib <- as_tibble(s4_df2)
s6_tib <- as_tibble(s6_df2)
# ================================================================
# 3) Join with weather data
# ================================================================

#read in weather data
season4weather <- read.csv("~/phenophasebbn/season_4_weather_gdd2020-05-08T203153.csv")
season6weather <- read.csv("~/phenophasebbn/weather_station_gdd_season_6_2020-06-25T205200.csv")

#left join weather and
s4combined <- as.data.frame(left_join(s4_tib, season4weather, by = "date"))
s6combined <- as.data.frame(left_join(s6_tib, season6weather, by = "date"))


#write out tsv file
write.table(s4combined, file = "~/phenophasebbn/s4combined.txt",
            quote = FALSE, sep = "\t")

write.table(s6combined, file = "~/phenophasebbn/s6combined.txt",
            quote = FALSE, sep = "\t")
