#!/usr/bin/env Rscript

library(tidyverse)
library(wavelets)

# load seasonal data from first preprocessing step
s4_df <- read.table(file = "~/phenophasebbn/season4_combined.txt", sep = "\t", header = TRUE,
           stringsAsFactors = FALSE)

plot(x = s4_df$day_of_year, y = s4_df$vpd_mean)
s4_vpd_fft <- fft(z = c(s4_df$day_of_year,s4_df$vpd_mean), inverse = TRUE)
# load relative growth rates from seasons 4 and 6 at MAC
rgr <- read.table(file = "~/phenophasebbn/jags/mac_growth_rate_modeled.csv",
           sep = ",", header = TRUE, stringsAsFactors = FALSE)
# load relative abundance of SNPs by gene per cultivar
snp_rel <- as.data.frame(t(as.matrix(read.table(file = "~/phenophasebbn/genomic_preprocessing/genewise_snp_relative_abundance.txt",
                      sep = "\t", header = TRUE, stringsAsFactors = FALSE))))

snp_rel_geno <- rownames_to_column(snp_rel, "genotype")

# join datasets

# export combined data for use with causalnex python library



