"rnaseq_GSE61999_norm_counts.csv": 
-a csv downloaded from http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE61999
-study number GSE61999
-from publication Durinck et al., Haematologica 2014 Dec;99(12):1808-16. PMID: 25344525

"rnaseq_GSE61999_annotation.csv":
-annotation file created based on sample annotations on GEO

"ensembl_df.csv":
-gene annotation file containing: ensembl_gene_id, hgnc_symbol, chromosome_name, entrezgene
-created in R using the the bioconductor package biomRt with the following commands:

source("http://bioconductor.org/biocLite.R")
biocLite("biomaRt")
library(biomaRt)
ensMart<-useMart("ensembl")
ensembl_hs_mart <- useMart(biomart="ensembl", dataset="hsapiens_gene_ensembl")
ensembl_df <- getBM(attributes=c("ensembl_gene_id", "hgnc_symbol","chromosome_name", "entrezgene"),
                    mart=ensembl_hs_mart) 
