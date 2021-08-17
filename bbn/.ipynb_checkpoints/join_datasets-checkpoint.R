#!/usr/bin/env Rscript
library(tidyverse)

# load relative growth rates from seasons 4 and 6 at MAC
rgr <- read.table(file = "~/work/phenophasebbn/jags/mac_growth_rate_modeled.csv",
           sep = ",", header = TRUE, stringsAsFactors = FALSE)
# load relative abundance of SNPs by gene per cultivar
snp_rel <- as.data.frame(t(as.matrix(read.table(file = "~/work/phenophasebbn/genomic_preprocessing/genewise_snp_relative_abundance.txt",
                      sep = "\t", header = TRUE, stringsAsFactors = FALSE))))
#rename var to do join
snp_rel_geno <- rownames_to_column(snp_rel, "genotype")

# join datasets

#subset relative growth rate modeling 
rgr_sub <- rgr %>% 
          select(season, genotype, max_growth_cm_gdd)
# join with snp data
joined_pheno <- left_join(snp_rel_geno, rgr_sub, by = "genotype")

#test for NA's
#join_fails <- which(is.na(joined_pheno), arr.ind = TRUE)
#fail_cols <- unique(join_fails[,2])
# columns that failed were: 4457 4458
#length(unique(joined_pheno$genotype))
#dropped_df <- na.omit(joined_pheno)

dropped_df <- na.omit(joined_pheno)
#length(unique(dropped_df$genotype))

# export combined data for use with causalnex python library
write_csv(dropped_df, file = "~/work/phenophasebbn/bbn/rgr_snp_joined.csv",
                    col_names = TRUE)

