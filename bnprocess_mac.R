#load libraries
library(tidyverse)
library(lubridate)
library(ggplot2)

# ================================================================
# 1) Trait data preprocessing, MAC only due to density of plant heights 
# ================================================================

# add wget statements for tall format data
#season four
system('wget https://de.cyverse.org/dl/d/B3ADF887-BDE3-435B-9301-4C3FCB4F56F1/tall_season_four.csv')
#season six (no change from raw data)
system('wget https://de.cyverse.org/dl/d/FD84112F-FCEA-4089-8486-B1D19D71300B/mac_season_six_2020-04-22.csv')

# read in CSV filepaths as list
data_path <- list("tall_season_four.csv", "mac_season_six_2020-04-22.csv")

# use lapply to read in csv files from list
  # note: function wrapper necessary to provide input argument to read.csv
raw_data <- lapply(data_path, FUN = function(i){
  read.csv(i, header=TRUE, stringsAsFactors = FALSE)})

# name each dataframe in the list based on data_path list order
experiments <- c("mac_season_4", "mac_season_6")

names(raw_data) <- experiments

#convert to tibble
raw_data <- map(.x = raw_data, .f = function(i){as_tibble(i)})

# wide format data function --- need to edit this to match whatever nomenclature is chosen
first_pass <- function(i){
  j <- i %>%
    mutate(row = row_number()) %>%
    pivot_wider(id_cols = c(row, lat, lon, date, sitename,
                            cultivar, treatment),
                names_from = trait, values_from = mean)   %>% 
    select(-row)
  return(j)
}

#make a list of wide format tibbles
wide_trait_data <- vector(mode = "list", length = length(raw_data))
wide_trait_data <- lapply(raw_data, FUN = function(i){first_pass(i)})
names(wide_trait_data) <- experiments
# ================================================================
# 2) select traits 
# ================================================================

# #change "plant_height" to canopy height for clemson data
# #assuming that plant height == canopy height
# wide_trait_data$clemson <- rename(wide_trait_data$clemson, canopy_height = plant_height)

# # add location variable for each dataframe
# # ex.  mac, clemson, ksu
# 
# #mac season 4
# wide_trait_data$mac_season_4 <- add_column(wide_trait_data$mac_season_4,
#                           experiment = rep("mac_season_4", nrow(wide_trait_data$mac_season_4)))
# #mac season 6
# wide_trait_data$mac_season_6 <- add_column(wide_trait_data$mac_season_6,
#                                            location = rep("mac_season_6", nrow(wide_trait_data$mac_season_6)))
# #ksu
# wide_trait_data$ksu <- add_column(wide_trait_data$ksu,
#                                            experiment = rep("ksu", nrow(wide_trait_data$ksu)))
# 
# #clemson
# wide_trait_data$clemson <- add_column(wide_trait_data$clemson,
#                                   experiment = rep("clemson", nrow(wide_trait_data$clemson)))
# 
# 
#make a vector of colnames to use; these are shared across all 4 datasets
data2use <- c("sitename", "date", "cultivar", "canopy_height")


### need to rewrite this section for data to select
select_data <- function(df){
  j <- as.data.frame(df[, (colnames(df) %in% data2use)])
  return(j)
}

#cut extraneous data from datasets
filtered_trait_data <- vector(mode = "list", length = length(wide_trait_data))
filtered_trait_data <- map(.x = wide_trait_data, .f = function(df){select_data(df)})
names(filtered_trait_data) <- experiments

# ================================================================
# 3) filter by cultivars in all data sets (including genomic)
# ================================================================
# read in cultivar lookup table
all_cult <- read.csv(file = "cultivar_lookup_table.csv", header = TRUE,
                     stringsAsFactors = FALSE)

# first column is a character vector of all cultivars present across all seasons
# (0 = not in season, 1 = in season; therefore rowsum = 4 is in all)
# make character vector of all cultivars in mac seasons
all_cult$mac_total <- all_cult$season_4 + all_cult$season_6 + all_cult$genomic_data
cultivars4net <- as.vector(all_cult[all_cult$mac_total == 3, 1]) 
# 274 cultivars at 2 mac sites with genomic data

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

weather_raw <- list("mac_season_4_weather.csv", "mac_season_6_weather.csv")

# use map from purrr to read in csv files
raw_weather_data <- map(.x = weather_raw, .f = function(i){read.csv(i, header = TRUE, stringsAsFactors = FALSE)})

#assign names to list of dataframes
names(raw_weather_data) <- c("mac_season_4_weather", "mac_season_6_weather")

# colname sanity check
colnames(raw_weather_data$mac_season_4_weather)
colnames(raw_weather_data$mac_season_6_weather)

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
names(combined_tibbs) <- experiments

#only unique dates + sitename
combined_tibbs_unq <- vector(mode = "list", length = length(combined_tibbs))

#mac seasons 4 and 6 unique by site + date
for(i in 1:2){
combined_tibbs_unq[[i]] <- combined_tibbs[[i]] %>% distinct(date, sitename, .keep_all = TRUE)
}
#name list items
names(combined_tibbs_unq) <- experiments


#sanity check dimensions, appears that the size is cut in half for each dataframe
dim(combined_tibbs_unq[[2]])
dim(combined_tibbs[[2]])

# summarize cultivar statistics by season
cult_sum <- vector(mode = "list", length = length(combined_tibbs_unq))
for(i in 1:2){
  cult_sum[[i]] <- combined_tibbs_unq[[i]] %>% 
    group_by(cultivar) %>%
    summarize(count = length(canopy_height),
              min_height = min(canopy_height),
              max_height = max(canopy_height),
              min_date = min(date),
              max_date = max(date),
              dur_days = as.numeric(difftime(max(date), min(date), "days")),
              min_gdd = min(gdd),
              max_gdd = max(gdd),
              dens = count / dur_days) %>%
    arrange(dens)
}
#mac season 4 range 2017-04-13 to 2017-09-21
range(combined_tibbs_unq[[1]]$date)
#mac season 4 range 2018-04-20 to 2018-08-02
range(combined_tibbs_unq[[2]]$date)

#combine into single dataframe and plot by cultivar
mac <- do.call(rbind.data.frame, combined_tibbs_unq) %>%
  mutate(season = case_when(date <= as.Date("2017-12-31") ~ "season 4",
                            date >= as.Date("2018-01-01") ~ "season 6"),
         cultivar = factor(cultivar, levels = cult_sum[[1]]$cultivar)) %>%
  arrange(desc(season))

vars <- cult_sum[[1]]$cultivar
varslist <- split(vars, ceiling(seq_along(vars)/20))
for(i in 1:length(varslist)){
  sub <- subset(mac, cultivar %in% varslist[[i]])
  csum4 <- subset(cult_sum[[1]], cultivar %in% varslist[[i]]) %>%
    mutate(cultivar = factor(cultivar, levels = cult_sum[[1]]$cultivar))
  csum6 <- subset(cult_sum[[2]], cultivar %in% varslist[[i]]) %>%
    mutate(cultivar = factor(cultivar, levels = cult_sum[[1]]$cultivar))
  fig <- ggplot() +
    geom_point(data = sub, aes(x = gdd, y = canopy_height, col = season), alpha = 0.5) +
    geom_text(data = csum4, aes(x = 2000, y = 50, label = round(dens,3)), 
              color = "#F8766D", size = 3, hjust = 0, vjust = 0) +
    geom_text(data = csum6, aes(x = 0, y = 300, label = round(dens,3)), 
              color = "#00BFC4", size = 3, hjust = 0, vjust = 0) +
    facet_wrap(~cultivar, ncol = 4) +
    theme_bw()
  jpeg(filename = paste0("data_figs/height_vs_gdd_", i, ".jpg"), 
       height = 5, width = 8, units = "in", res = 300)
  print(fig)
  dev.off()
}

# Use the filtering criteria of at least n = 35  OR dens > = 0.4
sel_cults <- vector(mode = "list", length = length(cult_sum))
for(i in 1:2){
  sel_cults[[i]] <- cult_sum[[i]] %>% 
    filter(count >= 35 | dens >= 0.4) %>%
    select(cultivar)
}
# Results in 262 cultivars from MAC season 4 and 274 cultivars from MAC season 6

# Final selection
final_tibbs <- vector(mode = "list", length = length(combined_tibbs_unq))
for(i in 1:2){
  final_tibbs[[i]] <- combined_tibbs_unq[[i]] %>% 
    filter(cultivar %in% sel_cults[[i]]$cultivar)
}
names(final_tibbs) <- experiments
#compare rows
lapply(final_tibbs, nrow)
lapply(combined_tibbs_unq, nrow)
#same number of rows for season 6, fewer rows in season 4

#write out season6 for growth curves
write.table(final_tibbs$mac_season_6, file = "season6_combined.txt",
            quote = FALSE, sep = "\t")
write.table(final_tibbs$mac_season_4, file = "season4_combined.txt",
            quote = FALSE, sep = "\t")

#combine all location final_tibbs
bn_input <- bind_rows(combined_tibbs)

write.table(bn_input, file = "bn_input.txt",
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
bn_pca <- as.data.frame(na.omit(bn_input[,c(3,6:15)]))
bn_num_pca <- prcomp(bn_pca, scale. = TRUE, center = TRUE)
s4_test_pca <- prcomp(combined_tibbs$mac_season_4[,c(3,9,14,15)], scale. = TRUE)
library(ggfortify)
s4_pca_plot <- autoplot(s4_test_pca, data = combined_tibbs$mac_season_4[,2:17], colour = 'vpd_mean')
bn_pca_plot <- autoplot(bn_num_pca, data = bn_pca, colour = 'vpd_mean',
                        loadings = TRUE, loadings.colour = 'blue',
                        loadings.label = TRUE, loadings.label.size = 3)

bn_winnowed <- as.data.frame(na.omit(bn_input[,c(3,9,13,15)]))
bn_winnowed_pca <- prcomp(bn_winnowed, scale. = TRUE, center = TRUE)
bn_winnowed_pca_plot <- autoplot(bn_winnowed_pca, data = bn_pca, colour = 'vpd_mean',
                        loadings = TRUE, loadings.colour = 'blue',
                        loadings.label = TRUE, loadings.label.size = 3)
bn_winnowed_pca_plot
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

fit.weibull <- fitdist(bn_input$canopy_height, "weibull")
qqplot(qweibull(ppoints(length(bn_input$canopy_height)), shape = 1.074721, 
                        scale = 142.662183), bn_input$canopy_height)
