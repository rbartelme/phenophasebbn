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
cut_data <- function(df){
  j <- as.data.frame(df[, !(colnames(df) %in% data2cut)])
  return(j)
}

#cut extraneous data from datasets
cut_trait_data <- list()
cut_trait_data <- map(.x = wide_trait_data, .f = cut_data)
# ================================================================
# 2) filter by cultivars in all data sets (including genomic)
# ================================================================
# read in cultivar lookup table - this will also need wget
all_cult <- read.csv(file = "~/phenophasebbn/cultivar_look_up_2020-05-22.csv")

# convert to dataframe
cult_df <- as.data.frame(all_cult)

# first column is a character vector of all cultivars present across all seasons
# (0 = not in season, 1 = in season; therefore rowsum = 4 is in all)
# make character vector of all cultivars in all seasons
cultivars4net <- cult_df[rowSums(cult_df[, 2:5]) == 4, 1]

#define filter cultivar function
filter_cultivar <- function(df){
  j <- as.data.frame(df[df$cultivar %in% cultivars4net, ])
  return(j)
}

#filtered by cultivars
filtered_trait_data <- list()
filtered_trait_data <- map(.x = cut_trait_data, .f = filter_cultivar)

#remove all na canopy heights
fix_canopy_height <- function(df){
  j <- as.data.frame(df[!is.na(df$canopy_height), ])
  return(j)
}
fixed_trait_data <- list()
fixed_trait_data <- map(.x = filtered_trait_data, .f = fix_canopy_height)

#convert season 4 dataframe to tibble
trait_tibbs <- list()
trait_tibbs <- map(.x = fixed_trait_data, .f = as_tibble())

# ================================================================
# 3) Join with weather data
# ================================================================

weather_raw <- list("filepath1", "filepath2", "filepath3")

# use map from purrr to read in csv files
raw_weather_data <- map(.x = weather_raw, .f = read.csv())

#left join weather and
merge_trait_weather <- function(list_a, list_b){
  if(length(list_a) == length(list_b)){
    for(i in 1:length(list_a)){
    m <- as.data.frame(left_join(list_a[[i]], list_b[[i]], by = "date"))
    return(m)}
  }else(print("Error: data frame list lengths are not equal."))
}

#add naming statement?

#write out tsv file

clean_write_out <- function(m){
  for(i in 1:length(m)){
  wd <- getwd()
  df_name <- names(m[[i]])
  location <- paste0(wd, '/', df_name, '.txt')
  write.table(df, file = location, quote = FALSE, sep = "\t")
  }
}


