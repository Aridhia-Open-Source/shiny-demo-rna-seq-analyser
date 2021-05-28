# RNA-Seq Analyser

RNA-sequecing or RNA-seq is part of the next-generation sequencing techniques. RNA-seq aims to identify which genes are being expressed in the sample at the time it was taken, this is the **Gene Expression Profile**, which provides:

- *Qualitative information*: Which genes are being expressed
- *Quantitative information*: What is the level of expression

While all the cells in our body contain the same genomic information, expression patterns change between cells or tissues. Studying RNA expression captures dynamic information about gene expression within a cell, which informs about the cell's gene regulation and can be indicative of the cell's response to a stimulus. (e.g. cells that have been treated vs untreated with a drug, OR cells from a diseased tissue vs a cells from a normal tissue). When comparing gene expressed genes, it is possible to identify a number of genes that are key drivers of a cellular response to a treatment or disease or can serve as biomarkers for patient stratification. 

Data from RNA-seq needs to be processed before useful information can be extracted from it, data from each sample is usually passed through a pipeline of processing stages. The output of a sequencer is a **fastq** file, which is a list of short sequences, this has to be transformed into a file container the level of expression of every gene or **read counts**.

The pipeline consists of:

1. Adaptor trimming - adaptors are added during the RNA-seq to facilitate the sequencing process. If the sequence of these adaptors is known, they can be removed to improve accuracy of alignment.
2. Quality control before alignment
3. Alignment - is the process of determining where does each sequenced read come from based on a reference genome. This step requires a reference genome (fastq file), a known transcript (gtf file - optional) and the sequencing result (fastq file). The output is a SAM (Sequence Alignment Map) file, which is a tab-delimited text file, or a BAM file, which is the binary version of a SAM file and is preferred by some softwares (e.g. IGV).
4. Quality control of alignment
5. Getting read counts - from the alignment output, the number of reads for every position of the genome is extracted. The R package Rsubread, takes a SAM file as an input and returns the read counts as a CSV file.

## Analysis included in the app

**Principal Component Analysis (PCA)** is a way to "bring out" strong patterns from large and complex datasets. These plots show an overview of the grouping of samples based on their gene expression profile.

**Gene Clusters** with similar expression profiles can be identified using an unsupervised clustering algorithm specified by the user. Gene expression is plot as a heatmap, where rows represent genes and columns represent samples, and the relative level of each gene is represented by colour (red = high expression, green = low expression). Columns and rows are clustered, which enables the visualisation of groups of samples with similar expression profiles.

**Differential Gene Expression Analysis** is used to identify genes of interest, as it highlights the genes whose expression has changed the most between samples. It shows the comparison of expression level of each gene between two groups of samples. Every point represents a gene, plotted by log2 fold change between sample groups and log2 mean expression level. 

**Quality Control Summary** shows an overview of the different pipeline stages and alignment summary.

## Data

The data for this demo app was obtained from:

- RNA-seq results (rnaseq_GSE61999_norm_counts.csv) was downloaded from http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE61999. Study number GSE61999, from the publication Durinck et al., Haematologica 2014 Dec;99(12):1808-16. PMID: 25344525
- Annotation file (rnaseq_GSE61999_annotation.csv) was created based on sample annotations on Gene Expression Omnibus (GEO)
- Gene annotation file containing ensembl_gene_id, hgnc_symbol, chromosome_name, entrezgene (ensembl_df.csv"). Created in R using the the bioconductor package biomRt with the following commands:

```
source("http://bioconductor.org/biocLite.R")
biocLite("biomaRt")
library(biomaRt)
ensMart<-useMart("ensembl")
ensembl_hs_mart <- useMart(biomart="ensembl", dataset="hsapiens_gene_ensembl")
ensembl_df <- getBM(attributes=c("ensembl_gene_id", "hgnc_symbol","chromosome_name", "entrezgene"),
                    mart=ensembl_hs_mart) 
```


## Checkout and run

You can clone this repository by using the command:

```
git clone https://github.com/aridhia/demo-rna-seq-analyser
```

Open the .Rproj file in RStudio, source the script called `dependencies.R` to install all the packages required by the app and run `runApp()` to start the app.

## Deploying to the workspace

1. Create a new blank mini-app in the workspace called "RNA-seq" and delete the folder created for it
2. Download this GitHub repo as a ZIP file, or clone the repository and zip all the files
3. Upload the ZIP file to the workspace and unzip it inside a folder called "RNA-seq"
4. Run the `dependencies.R` script to install all the packages required by the app
5. Run the app in your workspace

For more information visit https://knowledgebase.aridhia.io/article/how-to-upload-your-mini-app/

