# Cleaning MAC weather data

require(plantecophys)
library(dplyr)
library(readr)

s4_url <- 'https://de.cyverse.org/dl/d/7D6C8FD6-EF77-437C-89E6-412EA8C3EEC6/mac_weather_station_raw_daily_2017.csv'
s6_url <- 'https://de.cyverse.org/dl/d/233C21D5-1306-4028-9CF9-FF4AF0EAC405/mac_weather_station_raw_daily_2018.csv'

url <- 'https://de.cyverse.org/dl/d/7D6C8FD6-EF77-437C-89E6-412EA8C3EEC6/mac_weather_station_raw_daily_2017.csv'
season_number = 4
format_weather <- function(season_number, url) {
  download.file(url, paste0("mac_season_", season_number, ".csv"))
  
  weather <- read.csv(paste0("mac_season_", season_number, ".csv")) %>%
    mutate(date = as.POSIXct((weather$day_of_year-1)*24*60*60, 
                             origin = paste0(unique(weather$year), "-01-01"), tz = "America/Phoenix"),
           daily_gdd = ifelse((air_temp_max + air_temp_min)/2 < 10, 10, (air_temp_max + air_temp_min)/2 - 10),
           gdd = cumsum(daily_gdd),
           cum_precip = cumsum(precip_total))
  
  # Save out, append date of retrieval?
  
}