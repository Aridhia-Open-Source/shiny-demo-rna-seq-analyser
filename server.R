
server <- shinyServer(function(input, output, session) {  
  
  
  
  ##### DATA SUBSET #####
  norm_counts <- reactive({
    all_norm_counts[all_norm_counts$run_id == input$run_id, ]
  })
  
  annotation <- reactive({
    all_annotation[all_annotation$run_id == input$run_id, ]
  })
  
  pca <- reactive({
    n_counts <- norm_counts()[, -c(13, 14)]
    prcomp(t(n_counts), center = TRUE, scale. = TRUE)
  })
  
  pca_exp_var_df <- reactive({
    pca_exp_var <- round(pca()$sdev^2 / sum(pca()$sdev^2) * 100, 1)
    pca_exp_var_df <- data.frame(principal_component = factor(paste0("PC", 1:12), levels = paste0("PC", 1:12)),
                                 variance_explained = pca_exp_var)
    
    pca_exp_var_df
  })
  
  pca_dat <- reactive({
    out <- merge(annotation(), pca()$x, by.x = "sample", by.y = "row.names" )
    out$id <- 1:nrow(out)
    out
  })
  
  ##### HEATMAP #####
  norm_counts_var <- reactive({
    which <- apply(norm_counts()[, -c(13, 14)], 1, ffun)
    norm_counts()[which, -c(13, 14)]
  })
  
  lab_col <- reactive({
    ann <- annotation()
    paste0(ann$sample, "\n (", ann$treatment, " ", ann$time, ")")
  })
  
  output$distPlot <- renderPlot({
    #specify distance matrix
    dist_choice <- function(d) dist(d, method = input$dist, diag = FALSE, upper = FALSE, p = 2)
    
    #specify aggplomeration method
    hclust_choice <- function(d) hclust(d, method = input$select, members = NULL)
    
    par(oma=c(5.5,4,4,2))
    
    heatmap.2(
      as.matrix(log2(norm_counts_var())),
      dendrogram = c("both"),
      distfun = dist_choice,
      hclustfun = hclust_choice,
      scale = c("row"),
      trace = c("none"),
      col = colorRampPalette(c("green", "black", "red"))(n=1000),
      labCol = lab_col(),
      labRow = FALSE,
      ColSideColors = rep(cc, 3),
      density.info = c("none"),
      cexCol = 1.5,
      key = TRUE
    )
  })
  
  
  ##### PCA SCATTERPLOT #####
  var_tooltip <- function(x) {
    paste0("Accounts for ", x$variance_explained, "%", "<br /> of overall variabilty")
  }
  
  ggvis(pca_exp_var_df) %>%
    layer_paths(~principal_component, ~variance_explained) %>%
    layer_points(~principal_component, ~variance_explained, fillOpacity := 0, stroke := "black",
                 fill := "black", fillOpacity.hover := 1) %>%
    add_tooltip(var_tooltip) %>%
    set_options(width = "auto") %>%
    bind_shiny("var_exp")
  
  pca_plot <- reactive({
    out <- pca_dat()[, c("sample", "cell_line", "treatment", "time", "replicate", "names", "condition",
                         input$select_pca1, input$select_pca2, "id")]
    names(out) <- c("sample", "cell_line", "treatment", "time", "replicate", "names", "condition",
                    "PCx", "PCy", "id")
    out
  })
  
  
  
  # function to add to tool tip
  pca_all_values <- function(x) {
    if(is.null(x)) return(NULL)
    row <- pca_plot()[pca_plot()$id == x$id, ]
    paste0(names(pca_plot()), ": ", format(row), collapse = "<br />")
  }
  
  ggvis(pca_plot) %>% 
    layer_points(~PCx, ~PCy, fill = ~condition, key := ~id, size := 40, size.hover := 80, opacity := 0.9, opacity.hover := 1) %>%
    add_tooltip(pca_all_values) %>%
    set_options(height = 600, width = "auto") %>%
    add_axis("x", title = "x") %>%
    add_axis("y", title = "y") %>%
    bind_shiny("ggvis_output_pca")
  
  
  ##### FOLD CHANGE #####
  
  log2fc <- reactive({
    n_counts <- norm_counts()[, -c(13, 14)]
    
    # calculate mean of treated samples
    a <- apply((n_counts[, c(annotation()$treatment == "Treated")]), 1, mean)
    
    # calculate the mean of untreated samples
    b <- apply((n_counts[, c(annotation()$treatment == "Control")]), 1, mean)
    
    #calculate changes in treated vs untreated
    fc <- a/b
    log2fc <- log(fc, 2)
  })
  #calculate the mean expression of every gene
  #mean_exprs <- apply(norm_counts, 1, mean)
  
  mean_exprs <- reactive({
    n_counts <- norm_counts()[, -c(13, 14)]
    rowMeans(n_counts)
  })
  
  log2_mean_exprs <- reactive({
    log(mean_exprs(), 2)
  })
  
  my_genes_ann <- reactive({
    ensembl_df[match(norm_counts()$ensembl_gene_id, ensembl_df$ensembl_gene_id), ]
  })
  
  
  exp_dat <- reactive({
    data.frame(
      Gene_symbol = my_genes_ann()$hgnc_symbol,
      Ensembl_id = my_genes_ann()$ensembl_gene_id,
      Log2_mean_exprs = log2_mean_exprs(),
      Log2fc = log2fc(),
      id = paste(1:length(log2fc()), ":1:", my_genes_ann()$hgnc_symbol,":2:", my_genes_ann()$ensembl_gene_id, sep = ""),
      Significant_genes = as.character(abs(log2fc()) > input$log2fc)
    )
  })
  
  
  all_values1 <- function(x) {
    if(is.null(x)) return(NULL)
    
    x$id2 <- gsub(":1:.+$", "", x$id)
    x$hgnc_ensembl <- gsub("^.+:1:", "", x$id)
    
    x$HGNC_Symbol  <- gsub(":2:.+$", "", x$hgnc_ensembl)
    x$Ensembl_id <- gsub("^.+:2:", "", x$hgnc_ensembl)
    
    x$id <- NULL
    x$id2 <- NULL
    x$hgnc_ensembl <- NULL
    
    paste0(names(x), ": ", format(x), collapse = "<br />")
  }
  
  #plot scatter plot in ggvis
  ggvis(exp_dat) %>% 
    layer_points(~Log2_mean_exprs, ~Log2fc, fill= ~Significant_genes, key:= ~id, opacity := 0.7,
                 opacity.hover := 1, size := 20, size.hover := 40) %>%
    add_tooltip(all_values1) %>%
    set_options(height = 800, width = "auto") %>%
    bind_shiny("ggvis_output_exp_fold_change")        
  
  
  ##### QC PLOTS #####
  align_stats_run <- reactive({
    star_align_qc <- star_align_qc[star_align_qc$run_id == input$run_id, ] 
    
    align_stats <- star_align_qc[c(grep("Uniquely mapped reads %",star_align_qc$star_align_metric),
                                   grep("% of reads mapped to multiple loci",star_align_qc$star_align_metric),
                                   grep("% of reads mapped to too many loci",star_align_qc$star_align_metric),
                                   grep("% of reads unmapped: too many mismatches",star_align_qc$star_align_metric),
                                   grep("% of reads unmapped: too short",star_align_qc$star_align_metric),
                                   grep("% of reads unmapped: other",star_align_qc$star_align_metric)),] 
    
    #relabel categories
    align_stats[,3] <- factor(c("Uniquely mapped", "Mapped to multiple loci", "Mapped to too many loci", "Unmapped: too many mismatches", "Unmapped: too short", "Unmapped: other"))
    align_stats[,3] <- factor(align_stats[,3], levels=c("Uniquely mapped", "Mapped to multiple loci", "Mapped to too many loci", "Unmapped: too many mismatches", "Unmapped: too short", "Unmapped: other"))
    
    #remove % from values
    align_stats[,4] <- as.numeric(gsub("%","", align_stats[,4]))
    
    align_stats
  })
  
  align_tooltip <- function(data) {
    
    #str(data)
    paste0(data$count_, "%")
    
  }
  
  align_stats_run %>% 
    ggvis(x = ~star_align_metric, y = ~star_align_value, fill.hover := "red") %>% 
    layer_bars(stack = FALSE) %>%
    add_tooltip(align_tooltip) %>%
    set_options(height = 480, width = "auto") %>%
    add_axis("x", title = "STAR Alignment metric", title_offset = 100, properties = axis_props(          
      #grid = list(stroke = "black"),
      ticks = list(stroke = "black", strokeWidth = 1),
      labels = list(angle = 30, align = "left")
    )) %>%
    add_axis("y", title = "Value") %>%
    bind_shiny("ggvis_output_align_qc")    
  
  
  output$pipeline_results <- renderTable ({    
    wide_star_align <- reshape(star_align_qc, v.names = "star_align_value", idvar = "run_id",
                               direction = "wide", timevar = "star_align_metric")
    
    names(wide_star_align) <- gsub("star_align_value.", "", names(wide_star_align))
    names(wide_star_align) <- gsub(" ", "", names(wide_star_align))
    
    out <- merge(wide_star_align, pipeline_stages[, c("run_id", "exit_status")], by = "run_id")
    
    out <- out[, c(1,16,17,30,4,5,6,7,18)]
    names(out) <- c("Run Id", "Started On", "Finished On", "Exit Status", "Million Reads Per Hour", "Mean Input Read Length", "% Uniquely Mapped Reads", "Number of Splices", "Number of Input Reads")
    out
  })
})


