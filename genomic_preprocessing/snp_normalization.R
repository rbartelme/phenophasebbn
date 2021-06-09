system("cd ~/work && wget https://github.com/genophenoenvo/genomic_data/blob/master/FriendsOfEntropy/gene_cultivar_call.dataframe.gz?raw=true")
system("mv ~/work/gene_cultivar_call.dataframe.gz?raw=true ~/work/gene_cultivar_call_dataframe.gz")
system("gzip -d ~/work/gene_cultivar_call_dataframe.gz")

gene_df <- read.table(file = "~/work/gene_cultivar_call_dataframe", sep = "\t",
                      header = TRUE, row.names = 1)

rel_snp_by_gene <- as.data.frame(prop.table(as.matrix(gene_df), 1))
write.table(rel_snp_by_gene, file = "~/work/genewise_snp_relative_abundance.txt", sep = "\t", row.names = TRUE, col.names = TRUE)

rel_test <- read.table(file = "~/work/snp_normalization.R", row.names = 1, header = TRUE)
