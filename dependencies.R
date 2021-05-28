library(shiny)
library(shinydashboard)
library(ggvis)
library(gplots)
library(stats)
library(ggplot2)
library(readr)


# Packages used by the app
packages <- c("shiny", "shinydashboard", "ggvis", "ggplots", "stats", "ggplot2", "readr")

# Install packages if not installed
package_install <- function(x){
  
  for (i in x){
    if (!require(i, character.only = TRUE)){
      install.packages(i)
    }
  }
  
}

package_install(packages)