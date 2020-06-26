
<!-- README.md is generated from README.Rmd. Please edit that file -->

# getarc

# Overview

getarc provides a few functions for querying feature server data via the
ArcGIS RestAPI.

# Installation

The package can currently be installed from github:

``` r
# Install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("matthewjwhittle/getarc")
```

# Examples

``` r
library(osgridref)

grid_refs <- c("TA 304 403", "SE 2344 0533", "SE13", "SE 23444 05334")
# Returns a tibble of X and Y coords and their resolution
gridref_to_xy(grid_refs)
```

    ## # A tibble: 4 x 3
    ##        x      y resolution
    ##    <dbl>  <dbl>      <dbl>
    ## 1 530400 440300        100
    ## 2 423440 405330         10
    ## 3 410000 430000      10000
    ## 4 423444 405334          1
