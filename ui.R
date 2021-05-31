

#pipeline_stages <- xap.read_table("pipeline_harness_stages")

run_ids <- unique(pipeline_stages[,c("run_id")])
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("PCA Analysis", tabName = "pca_analysis", icon = icon("line-chart")),
    menuItem("Gene Clustering", tabName = "clustered_genes", icon = icon("line-chart")),
    menuItem("Gene Expression Fold Changes", tabName = "gene_expression", icon = icon("line-chart")),
    menuItem("QC Summary", tabName = "rnaseq_summary", icon = icon("bar-chart")),
    menuItem("Help Tab", tabName = "help_tab", icon = icon("question-circle"))
    
  ),
  selectInput("run_id", "Run:", choices = run_ids, selected = "run_ABg6q94")
)

body <- dashboardBody(
  includeCSS("./www/styles.css"),
  
  # Browser tab title
  titlePanel(
    windowTitle = "RNA-seq Analyser",
    title = tags$head(tags$link(rel = "shortcut icon", href="favicon.ico"))
  ),
  
  
  tabItems(
    tabItem(tabName = "pca_analysis",
      # Application title
      h1("Visualising the distribution of treatment and control datasets"), 
      br(),
      br(),
      fluidRow(
        box(width = 8, title = h2("Principal Component Analysis"), solidHeader = FALSE,
          ggvisOutput("ggvis_output_pca") 
        ),
        column(4,
          box(title = h2("Inputs"), solidHeader = FALSE, width = 12,
            selectInput("select_pca1", label = h5("Select Principal Component for x-axis"),
                        choices = paste0("PC", 1:12), selected = "PC1"),
                         
            selectInput("select_pca2", label = h5("Select Principal Component for y-axis"),
                        choices = paste0("PC", 1:12), selected = "PC2")
          ),
          box(title = "Explained Variance", solidHeader = FALSE, width = 12,
            ggvisOutput("var_exp")
          )
        )
      )
    ),
    tabItem(tabName = "clustered_genes",
      h1("Identifying clusters of samples and genes"), 
      br(),
      br(),
      fluidRow(
        box(title = h2("Clustered Gene Expression Profile"), width = 10, solidHeader = FALSE,
          div(style = "height:750px;",
            plotOutput("distPlot", height = "100%")   
          )   
        ),
        box(title = h2("Inputs"), solidHeader = FALSE, width = 2,
          selectInput("select", label = h5("Agglomeration method"), 
                      choices = list("ward", "single", "complete","average", "mcquitty", "median", "centroid"), 
                      selected = "complete"),
                
          selectInput("dist", label = h5("Distance method"), 
                      choices = list("euclidean", "maximum", "manhattan", "canberra", "binary", "minkowski"), 
                      selected = "euclidean")
        )
      )
    ),    
    tabItem(tabName = "gene_expression",
      h1("Differential gene expression analysis"), 
      br(),
      br(),
      fluidRow(
        box(title = h2("Gene Expression Log Fold Changes"), width = 8, solidHeader = FALSE,       
          div(style = "height:750px;width:800px",
            plotOutput("output_exp_fold_change", height = "100%", width = "100%")   
          )   
        ),
        box(title = h3("Inputs"), width = 4, solidHeader = FALSE,
          sliderInput("log2fc", "log2FC:", min = 1, max = 3, value = 1.5, step = 0.5)
        )
      )
    ),
    tabItem(tabName = "rnaseq_summary",
      fluidRow(
        box(title = "Tracked Pipeline Stages", width = 12, solidHeader = FALSE,       
            tableOutput("pipeline_results")    
        )
      ),
      fluidRow(
        box(title = "Alignment Summary", width = 8, solidHeader = FALSE,       
            ggvisOutput("ggvis_output_align_qc")    
        )#,
        #box(title = "Inputs", width = 4, solidHeader = TRUE, status = "warning",                  
        #    selectInput("run_id", "Run:", choices=run_ids, selected="run_ABg6q94")##TODO automatically list all levels of run_ids in table
        #)
      )
    ),
    tabItem(tabName = "help_tab",
            fluidRow(documentation_tab()))
  )
)

# Put them together into a dashboardPage
dashboardPage(
  dashboardHeader(disable = TRUE),
  sidebar,
  body
)

