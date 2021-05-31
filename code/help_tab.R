documentation_tab <- function() {
  tabPanel("Help",
           fluidPage(width = 12,
                     fluidRow(column(
                       6,
                       h3("RNA-Seq Analyser"), 
                       p("This mini-app allows you to perform the analysis of RNA-seq results."),
                       h4("To use the mini-app"),
                       p("The datasets available in the app are located in the 'data' folder, if you wish to a different dataset, you can save the CSV file in the 'data' folder. You can also change the code to read files from another location." ),
                       tags$ol(
                         tags$li(strong("Principal Component Analysis (PCA)"), " is a method used to highlight grouping patterns from large and complex datasets. In this example, it is possible to observe clusters by treatment type and duration."), 
                         tags$li(strong("Gene Clustering"), 
                                 " uses a heatmap where ows represent genes and columns represent samples, and the relative level of each gene is represented by colour 
                                 (red = high expression, green = low expression). Columns and rows are clustered, which enables the visualisation of groups of samples 
                                 with similar expression profiles. This allows to identify clusters of samples with similar expression profiles."),
                         tags$li(strong("Gene Expression Fold Change "), 
                                 "it is used to identify genes of interest, which change the most after treatment. Using the slider, you can change the treshold fold change
                                 value to highlight genes of interest."), 
                         tags$li(strong("Quality Control (QC) Summary "), "shows an overvie of the different pipeline stages and alignment summary.")
                       ),
                       br()
                     ),
                     #column(
                      # 6,
                       #h3("Walkthrough video"),
                       #tags$video(src="survival.mp4", type = "video/mp4", width="100%", height = "350", frameborder = "0", controls = NA),
                       #p(class = "nb", "NB: This mini-app is for provided for demonstration purposes, is unsupported and is utilised at user's 
                       #risk. If you plan to use this mini-app to inform your study, please review the code and ensure you are 
                       #comfortable with the calculations made before proceeding. ")
                       
                     #)
                     )
                     
                     
                     
                     
           ))
}