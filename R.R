install.packages("devtools")
install.packages("roxygen2")
library("devtools")
devtools::install_github("klutometis/roxygen")
library(roxygen2)

getwd()
dir ()

# create the skeleton of the package
create("kk")
setwd ("kk")

document()

setwd("..")
install("kk")

release ("kk")# for releasing the package to the CRAN