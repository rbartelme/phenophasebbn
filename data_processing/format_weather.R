# Obtaining MAC weather data + calculating gdd

format_weather <- function(id) {
  require(traits)
  options(betydb_url = "https://terraref.org/bety/",
          betydb_api_version = 'v1')
  
  # metadata of experiment, to obtain start and end dates
  meta <- betydb_experiment(id = id)
  st <- as.POSIXlt(meta$start_date, format = "%Y-%m-%d", tz = "America/Phoenix")
  en <- as.POSIXlt(meta$end_date, format = "%Y-%m-%d", tz = "America/Phoenix")
  # Unique years since 2000
  year <- unique(st$year, en$year) - 100
  
  # Extract site names
  sitenames <- unique(meta$sites$site.sitename)
  string_int <- paste(Reduce(intersect2, strsplit(sitenames, NULL)), collapse = '')
  string <- substr(string_int, 1, nchar(string_int) - 16)
  season <- gsub(" ", "_", gsub("MAC Field Scanner ", "", string))
  
  # Managements, to source earliest planting and latest harvest dates
  managements <- betydb_query(table = "managements") 
  
  plant <- managements %>%
    filter(mgmttype == "Planting" | mgmttype == "planting") %>%
    mutate(date = as.POSIXct(date)) %>%
    filter(date >= st & date <= en)
  
  harvest <- managements %>%
    filter(mgmttype == "Harvest" | mgmttype == "harvest") %>%
    mutate(date = as.POSIXct(date)) %>%
    filter(date >= st & date <= en)
  
  plant_date <- min(plant$date)
  harvest_date <- max(harvest$date)

  # Download, read in, and name columns of MAC weather data
  website <- paste0("https://cals.arizona.edu/azmet/data/06", year, "rd.txt")
  system2(command = "wget", args = website)
  fname <- paste0("06", year, "rd.txt") # 06 is the station number
  dat <- read.csv(fname, header = FALSE)
  colnames(dat) <- c("year", "day_of_year", "station_number", 
                     "temp_max", "temp_min", "temp_mean",
                     "rh_max", "rh_min", "rh_mean",
                     "vpd_mean", "solar_rad_total", "precip", 
                     "4_in_soil_temp_max", "4_in_soil_temp_min", "4_in_soil_temp_mean",
                     "20_in_soil_temp_max",	"20_in_soil_temp_min", "20_in_soil_temp_mean",
                     "wind_speed_mean",	"wind_vector_magnitude", "wind_vector_direction",
                     "wind_direction_std", "max_wind_speed", "heat_units",	
                     "eto_azmet", "eto_p_m", "vapor_pressure_mean",	"dewpoint_mean")

  # Wrangle
  weather <- dat %>%
    mutate(date = as.POSIXct((dat$day_of_year-1)*24*60*60, 
                             origin = paste0(unique(dat$year), "-01-01"), tz = "America/Phoenix")) %>%
    filter(date >= plant_date & date <= harvest_date) %>%
    mutate(daily_gdd = ifelse((temp_max + temp_min)/2 < 10, 10, (temp_max + temp_min)/2 - 10),
           gdd = cumsum(daily_gdd),
           precip_cumulative = cumsum(precip)) %>%
    select(date, day_of_year, 
           temp_min, temp_max, temp_mean, gdd, 
           rh_min, rh_max, rh_mean, vpd_mean, 
           precip, precip_cumulative)
  
  # Save out
  write.csv(weather, file = paste0(season, "_weather.csv"), row.names = FALSE)
  
  # Delete the intermediate .txt file
  system2(command = "rm", args = fname)
}

intersect2 <- function (x, y)
{
  y <- as.vector(y)
  y[match(as.vector(x), y, 0L)]
}
