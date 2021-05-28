# Packages
library(shiny)
library(shinydashboard)
library(ggvis)
library(gplots)
library(stats)
library(ggplot2)
library(readr)

################## CLUSTERING DATA ####################################

# get colors according to ggplots automated color hues
gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

# gene filter scripts
cv <- function (a = 1, b = Inf, na.rm = TRUE) {
  function(x) {
    sdx <- sd(x, na.rm = na.rm)
    if (is.na(sdx) || sdx == 0) 
      return(FALSE)
    val <- sdx/abs(mean(x, na.rm = na.rm))
    if (val < a) 
      return(FALSE)
    if (val > b) 
      return(FALSE)
    return(TRUE)
  }
}

filterfun <- function(...) {
  flist <- list(...)
  if (length(flist) == 1 && is.list(flist[[1]])) 
    flist <- flist[[1]]
  f <- function(x) {
    for (fun in flist) {
      fval <- fun(x)
      if (is.na(fval) || !fval) 
        return(FALSE)
    }
    return(TRUE)
  }
  class(f) <- "filterfun"
  return(f)
}

genefilter <- function (expr, flist) {
  if (is(expr, "ExpressionSet")) 
    expr <- exprs(expr)
  apply(expr, 1, flist)
}

cvfun <- cv(0.7,20)
ffun <- filterfun(cvfun)
cc <- gg_color_hue(4)    


############## FOLD CHANGE DATA #################################   
ensembl_df <- read_csv("data/ensembl_df.csv")
# calculate mean of treated samples
# a <- apply((norm_counts[, c(annotation$treatment == "Treated")]),1,mean)
# 
# # calculate the mean of untreated samples
# b <- apply((norm_counts[, c(annotation$treatment == "Control")]),1,mean)
# 
# #calculate changes in treated vs untreated
# fc <- a/b
# log2fc <- log(fc, 2)
# 
# #calculate the mean expression of every gene
# #mean_exprs <- apply(norm_counts, 1, mean)
# 
# mean_exprs <- rowMeans(norm_counts)
# 
# log2_mean_exprs <- log(mean_exprs, 2)
# my_genes_ann = ensembl_df[match(rownames(norm_counts), ensembl_df$ensembl_gene_id),]  

############### QC SUMMARY SECTION ################################
# star_align_qc <- xap.read_table("pipeline_harness_star_align")
# pipeline_stages <- xap.read_table("pipeline_harness_stages")
star_align_qc <- dget("data/pipeline_harness_star_align.txt")
pipeline_stages <- dget("data/pipeline_harness_stages.txt")
# STAR ALIGNMENT TABLE
align_stats <- star_align_qc[c(grep("Uniquely mapped reads %", star_align_qc$star_align_metric),
                               grep("% of reads mapped to multiple loci", star_align_qc$star_align_metric),
                               grep("% of reads mapped to too many loci", star_align_qc$star_align_metric),
                               grep("% of reads unmapped: too many mismatches", star_align_qc$star_align_metric),
                               grep("% of reads unmapped: too short", star_align_qc$star_align_metric),
                               grep("% of reads unmapped: other", star_align_qc$star_align_metric)), ]
# relabel categories
align_stats[, 3] <- factor(c("Uniquely mapped", "Mapped to multiple loci", "Mapped to too many loci",
                             "Unmapped: too many mismatches", "Unmapped: too short", "Unmapped: other"))
align_stats[, 3] <- factor(align_stats[,3], levels=c("Uniquely mapped", "Mapped to multiple loci",
                                                     "Mapped to too many loci", "Unmapped: too many mismatches",
                                                     "Unmapped: too short", "Unmapped: other"))
# remove % from values
align_stats[, 4] <- as.numeric(gsub("%", "", align_stats[, 4]))  

all_norm_counts <- read_csv("data/rnaseq_GSE61999_norm_counts_mult_runs.csv")
# rownames(all_norm_counts) <- all_norm_counts[,1]
# all_norm_counts <- all_norm_counts[,-1]
row_sub <- apply(all_norm_counts[, -c(13, 14)], 1, function(row) all(row !=0 ))
all_norm_counts <- all_norm_counts[row_sub,]
all_annotation <- read_csv("data/rnaseq_GSE61999_annotation_mult_runs.csv")
names(all_annotation) <- tolower(names(all_annotation))
# annotation$sample <- tolower(annotation$sample)
# change treatment name for readability on the plots
all_annotation$treatment <- sub("GSI", "Treated", all_annotation$treatment)
all_annotation$treatment <- sub("DMSO", "Control", all_annotation$treatment)
all_annotation$condition <- sub("GSI", "Treated", all_annotation$condition)
all_annotation$condition <- sub("DMSO", "Control", all_annotation$condition)

pipeline_stages <- dget("data/pipeline_harness_stages.txt")
