#load libraries
library(tidyverse)

# add wget statements for tall format data
#season four
system('wget https://de.cyverse.org/dl/d/B3ADF887-BDE3-435B-9301-4C3FCB4F56F1/tall_season_four.csv')
#season six (no change from raw data)
system('wget https://de.cyverse.org/dl/d/FD84112F-FCEA-4089-8486-B1D19D71300B/mac_season_six_2020-04-22.csv')
#ksu
system('wget https://de.cyverse.org/dl/d/42CBC44A-7923-41D3-B1EA-E1DF3E5ACDCC/tall_ksu_data.csv')
#clemson
system('wget https://de.cyverse.org/dl/d/A5B5E73A-B528-4704-BD62-F9995AD5EDB4/tall_clemson_data.csv')

# read in CSV filepaths as list
data_path <- list("tall_season_four.csv", "mac_season_six_2020-04-22.csv", "tall_ksu_data.csv", "tall_clemson_data.csv")

# use lapply to read in csv files from list
  # note: function wrapper necessary to provide input argument to read.csv
raw_data <- lapply(data_path, FUN = function(i){
  read.csv(i, header=TRUE)})

# name each dataframe in the list based on data_path list order
names(raw_data) <- c("mac_season_4", "mac_season_6", "ksu", "clemson")

#convert to tibble, needs indexing like above
raw_data <- map(.x = raw_data, .f = function(i){as_tibble(i)})

# wide format data function --- need to edit this to match whatever nomenclature is chosen
first_pass <- function(i){
  j <- i %>%
    mutate(row = row_number()) %>%
    pivot_wider(id_cols = c(row, lat, lon, date,
                            cultivar, treatment),
                names_from = trait, values_from = mean)   %>% 
    select(-row)
  return(j)
}

#make a list of wide format tibbles
wide_trait_data <- vector(mode = "list", length = length(raw_data))
wide_trait_data <- lapply(raw_data, FUN = function(i){first_pass(i)})

# ================================================================
# 1) cut traits and environmental variables
# ================================================================

#make a vector of colnames to remove; lodging_present has no values, drop it
data2cut <- c("sitename", "treatment", "trait_description", "method_name",
              "units", "year", "station_number", "surface_temperature", "lodging_present")


#column sanity check
colnames(wide_trait_data$mac_season_4)
colnames(wide_trait_data$mac_season_6) # no gdd_to_flowering in season 6 is this the right dataset??
colnames(wide_trait_data$ksu)
colnames(wide_trait_data$clemson) #plant_height needs to be canopy_height

### need to rewrite this section for data to select


#Note: future network versions should include time in a dynamic BBN
cut_data <- function(df){
  j <- as.data.frame(df[, !(colnames(df) %in% data2cut)])
  return(j)
}

#cut extraneous data from datasets
cut_trait_data <- vector(mode = "list", length = length(wide_trait_data))
cut_trait_data <- map(.x = wide_trait_data, .f = function(df){cut_data(df)})
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

system('wget https://de.cyverse.org/dl/d/E11D3666-CD04-426F-B833-85DB6B39C574/mac_season_4_weather.csv')
system('wget https://de.cyverse.org/dl/d/33B533EC-9EB0-4BB4-AAA2-650FAD4BD1D5/mac_season_6_weather.csv')
system('wget https://de.cyverse.org/dl/d/F9FE37D0-BF57-4238-9F61-71C1D34B0B18/ksu_weather.csv')
system('wget https://de.cyverse.org/dl/d/08675B05-F02E-4AB1-A934-8EFAD8DD3296/clemson_weather.csv')


weather_raw <- list("mac_season_4_weather.csv", "mac_season_6_weather.csv", "ksu_weather.csv",
                    "clemson_weather.csv")

# use map from purrr to read in csv files
raw_weather_data <- map(.x = weather_raw, .f = read.csv())

#left join weather and
merge_trait_weather <- function(list_a, list_b){
  if(length(list_a) == length(list_b)){
    for(i in 1:length(list_a)){
    m <- as.data.frame(left_join(list_a[[i]], list_b[[i]], by = "date"))
    return(m)}
  }else(print("Error: list of data frames are not of equal length."))
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


