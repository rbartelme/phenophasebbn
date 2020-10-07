#load libraries
library(tidyverse)
library(lubridate)

# ================================================================
# 1) Trait data preprocessing 
# ================================================================

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
  read.csv(i, header=TRUE, stringsAsFactors = FALSE)})

# name each dataframe in the list based on data_path list order
names(raw_data) <- c("mac_season_4", "mac_season_6", "ksu", "clemson")

#convert to tibble
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
# 2) select traits 
# ================================================================

#change "plant_height" to canopy height for clemson data
#assuming that plant height == canopy height
wide_trait_data$clemson <- rename(wide_trait_data$clemson, canopy_height = plant_height)

# add location variable for each dataframe
# ex.  mac, clemson, ksu

#mac season 4
wide_trait_data$mac_season_4 <- add_column(wide_trait_data$mac_season_4,
                          experiment = rep("mac_season_4", nrow(wide_trait_data$mac_season_4)))
#mac season 6
wide_trait_data$mac_season_6 <- add_column(wide_trait_data$mac_season_6,
                                           location = rep("mac_season_6", nrow(wide_trait_data$mac_season_6)))
#ksu
wide_trait_data$ksu <- add_column(wide_trait_data$ksu,
                                           experiment = rep("ksu", nrow(wide_trait_data$ksu)))

#clemson
wide_trait_data$clemson <- add_column(wide_trait_data$clemson,
                                  experiment = rep("clemson", nrow(wide_trait_data$clemson)))


#make a vector of colnames to use; these are shared across all 4 datasets
data2use <- c("experiment", "date", "cultivar", "canopy_height")


### need to rewrite this section for data to select
select_data <- function(df){
  j <- as.data.frame(df[, (colnames(df) %in% data2use)])
  return(j)
}

#cut extraneous data from datasets
filtered_trait_data <- vector(mode = "list", length = length(wide_trait_data))
filtered_trait_data <- map(.x = wide_trait_data, .f = function(df){select_data(df)})


# ================================================================
# 3) filter by cultivars in all data sets (including genomic)
# ================================================================
# read in cultivar lookup table
all_cult <- read.csv(file = "~/phenophasebbn/cultivar_lookup_table.csv", header = TRUE,
                     stringsAsFactors = FALSE)

# first column is a character vector of all cultivars present across all seasons
# (0 = not in season, 1 = in season; therefore rowsum = 4 is in all)
# make character vector of all cultivars in all seasons
cultivars4net <- as.vector(all_cult[all_cult$total_count == 5, 1])

#define filter cultivar function
filter_cultivar <- function(df){
  j <- as.data.frame(df[df$cultivar %in% cultivars4net, ])
  return(j)
}

#filtered by cultivars
trait_data <- vector(mode = "list", length = length(filtered_trait_data))
trait_data <- map(.x = filtered_trait_data, .f = function(df){filter_cultivar(df)})

#remove all na canopy heights
fix_canopy_height <- function(df){
  j <- as.data.frame(df[!is.na(df$canopy_height), ])
  return(j)
}
fixed_trait_data <- vector(mode = "list", length = length(trait_data))
fixed_trait_data <- map(.x = trait_data, .f = function(i){fix_canopy_height(i)})

#convert data frames in list to tibbles
trait_tibbs <- vector(mode = "list", length = length(fixed_trait_data))
trait_tibbs <- map(.x = fixed_trait_data, .f = function(i){as_tibble(i)})

#fix dates in datasets
for(i in 1:length(trait_tibbs)){
trait_tibbs[[i]]$date <- as_date(trait_tibbs[[i]]$date)
}

# ================================================================
# 4) Join with weather data
# ================================================================

system('wget https://de.cyverse.org/dl/d/6D959379-0442-41FE-8BEE-890866ACF037/mac_season_4_weather.csv')
system('wget https://de.cyverse.org/dl/d/C6219045-8114-4068-B924-8C2CD54AB9FD/mac_season_6_weather.csv')
system('wget https://de.cyverse.org/dl/d/F53F6574-CE80-408E-B8C8-8983CB287F96/ksu_weather.csv')
system('wget https://de.cyverse.org/dl/d/1EB28C81-10A1-4E1B-A406-1D0C6A20AF2D/clemson_weather.csv')


weather_raw <- list("mac_season_4_weather.csv", "mac_season_6_weather.csv", "ksu_weather.csv",
                    "clemson_weather.csv")

# use map from purrr to read in csv files
raw_weather_data <- map(.x = weather_raw, .f = function(i){read.csv(i, header = TRUE, stringsAsFactors = FALSE)})

#assign names to list of dataframes
names(raw_weather_data) <- c("mac_season_4_weather", "mac_season_6_weather", 
                             "ksu_weather", "clemson_weather")
# colname sanity check
colnames(raw_weather_data$mac_season_4_weather)
colnames(raw_weather_data$mac_season_6_weather)
colnames(raw_weather_data$ksu_weather)
colnames(raw_weather_data$clemson_weather)

#convert weather data list of df's to tibbles
weather_tibbs <- map(.x = raw_weather_data, .f = function(i){as_tibble(i)})

#convert dates in list to date object for join
for(i in 1:length(weather_tibbs)){
  weather_tibbs[[i]]$date <- as_date(weather_tibbs[[i]]$date)
}

#join subset weather data and trait data, changed function to all weather data

combined_tibbs <- vector(mode = "list", length = length(trait_tibbs))

#for loop to join as a dataframe

for(i in 1:length(trait_tibbs)){
  combined_tibbs[[i]] <- as.data.frame(left_join(trait_tibbs[[i]],
                            weather_tibbs[[i]], by = "date"), stringsasfactors = FALSE)
}
names(combined_tibbs) <- c("mac_season_4", "mac_season_6", "ksu", "clemson")


  #combine all location dataframes
bn_input <- bind_rows(combined_tibbs)

write.table(bn_input, file = "~/phenophasebbn/bn_input.txt",
            quote = FALSE, sep = "\t")

#========================================================================
# Modeling Sandbox
# =======================================================================
# Prototype Coding goes down here
#
#
#### Model Features by Site
# ============================================================
# canopy height vs. GDD
#use NLS with single trait data to fit all the variables
# based on Kristina Riemer's tutorial: https://terraref.github.io/tutorials/combining-trait-weather-and-image-datasets.html
# ============================================================
single_cultivar <- combined_tibbs$mac_season_6[combined_tibbs$mac_season_6$cultivar == "PI656026" & 
                                                 combined_tibbs$mac_season_6$canopy_height <= 200,]

plot(single_cultivar$date, single_cultivar$gdd)
plot(single_cultivar$date, single_cultivar$canopy_height)

c <- 200
a <- 0.1
y <- single_cultivar$canopy_height[3]
g <- single_cultivar$gdd[3]
b <- ((log((c/y) - 1)) - a)/g
model_single_cultivar <- nls(canopy_height ~ c / (1 + exp(a + b * gdd)), 
                             start = list(c = c, a = a, b = b),
                             data = single_cultivar)

summary(model_single_cultivar)
coef(model_single_cultivar)

single_c <- coef(model_single_cultivar)[1]
single_a <- coef(model_single_cultivar)[2]
single_b <- coef(model_single_cultivar)[3]

single_cultivar <- single_cultivar %>% 
  mutate(mean_predict = single_c / (1 + exp(single_a + single_b * gdd)))
ggplot(single_cultivar) +
  geom_point(aes(x = gdd, y = canopy_height)) +
  geom_line(aes(x = gdd, y = mean_predict), color = "orange") +
  labs(x = "Cumulative growing degree days", y = "Canopy Height")


#calculate inflection point of growth curve
inf_y <- (as.numeric(single_c) - as.numeric(single_a)) / 2
inf_x <- ((log((as.numeric(single_c) / inf_y) - 1)) - as.numeric(single_a)) / as.numeric(single_b)

ggplot(single_cultivar) +
  geom_point(aes(x = gdd, y = canopy_height)) +
  geom_line(aes(x = gdd, y = mean_predict), color = "orange") +
  geom_hline(yintercept = inf_y, linetype = "dashed") +
  geom_vline(xintercept = inf_x) +
  labs(x = "Cumulative growing degree days", y = "Canopy Height")

all_cultivars <- c(day = as.double(), cultivar = as.character(), canopy_height = as.numeric(), 
                   gdd_cum = as.numeric(), canopy_predict = as.numeric(), 
                   inf_y = as.numeric(), inf_x = as.numeric())

for(each_cultivar in unique(combined_tibbs$mac_season_6$cultivar)){
  each_cultivar_df <- filter(combined_tibbs$mac_season_6, cultivar == each_cultivar)
  each_cultivar_model <- nls(canopy_height ~ c / (1 + exp(a + b * gdd)), 
                             start = list(c = c, a = a, b = b), 
                             data = each_cultivar_df)
  model_c <- coef(each_cultivar_model)[1]
  model_a <- coef(each_cultivar_model)[2]
  model_b <- coef(each_cultivar_model)[3]
  each_cultivar_df <- each_cultivar_df %>% 
    mutate(canopy_predict = model_c / (1 + exp(model_a + model_b * gdd)), 
           inf_y = (as.numeric(model_c) - as.numeric(model_a)) / 2, 
           inf_x = ((log((as.numeric(model_c) / inf_y) - 1)) - 
                      as.numeric(single_a)) / as.numeric(single_b))
  all_cultivars <- rbind(each_cultivar_df, all_cultivars)
}

ggplot(all_cultivars) +
  geom_point(aes(x = gdd_cum, y = mean)) +
  geom_line(aes(x = gdd_cum, y = mean_predict), color = "orange") +
  facet_wrap(~cultivar, scales = "free_y") +
  geom_hline(yintercept = inf_y, linetype = "dashed") +
  geom_vline(xintercept = inf_x) +
  labs(x = "Cumulative growing degree days", y = "Canopy Height")




# Principle Component Analysis of VPD
# vpd_mean pca scaled
dist()
s4_mds <- cmdscale(d = combined_tibbs$mac_season_4[,c(3,9,14,15)], eig = TRUE)


s4_test_pca <- prcomp(combined_tibbs$mac_season_4[,c(3,9,14,15)], scale. = TRUE)
library(ggfortify)
s4_pca_plot <- autoplot(s4_test_pca, data = combined_tibbs$mac_season_4[,2:17], colour = 'vpd_mean')

#calculate correlation matrix of numeric data
R <- cor(combined_tibbs$mac_season_4[,c(3,9,13,14,15)])
#find eigenvalues and eigenvectors for correlation matrix
r_eign <- eigen(R)

for (r in r_eign$values) {
  print(r / sum(r_eign$values))
}

#==========================================================================
# Genomic Data Reduction
#==========================================================================
sorg_ibs <- read.table(file = "~/phenophasebbn/all_seasons_distance_nonan.txt",
                       sep = "\t", stringsAsFactors = FALSE, row.names = 1)
colnames(sorg_ibs) <- row.names(sorg_ibs)
sorg_ibs_mat <- as.matrix(sorg_ibs)
sorg_ibs_dist <- as.dist(sorg_ibs_mat)

#classical multidimensional scaling of SNP Centered IBS Matrix (Gower, 1966)
snp_mds <- cmdscale(d = sorg_ibs_dist, k= 200, eig = TRUE)
