# Checking dependencies
#devtools::install_github("datastorm-open/DependenciesGraphs")
library(DependenciesGraphs)
library(getarc) # The package in development
deps <- funDependencies("package:getarc", "query_layer")
plot(deps)
