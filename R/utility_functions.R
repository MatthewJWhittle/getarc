#' Lower Logical
#'
#' Convert a logical value to a lower case string
#'
#' This function converts TRUE or FALSE to the equivalent lower case string "true" or "false" for use in queries.
#' @param x logical vector
#' @return charactor vector
lower_logical <-
  function(x){
    stopifnot(is.logical(x))
    tolower(as.character(x))
  }
#' Modify vector
#'
#' Modify a vector using names
#'
#' This function combines two named vectors, replacing elements in x where their names have matches in y.
#' @param x a named vector to replace
#' @param y a named vector to combine with x
#' @return a named vector that is the combination of x and y, not containing any elements in x with matches in y
modify_named_vector <-
  function(x, y){
    x[names(y)] <- y
    return(x)
  }
#' Map Server
#'
#' Is an endpoint a map server
#'
#' Feature & Map servers have different formats of querying and data. This function checks an endpoint string and returns TRUE or FALSE.
#' @param endpoint a string defining an esri endpoint
#' @return TRUE or FALSE
#' @importFrom stringr str_detect
map_server <-
  function(endpoint){
    stopifnot(is.character(endpoint) && length(endpoint) == 1)
    stringr::str_detect(endpoint, "/MapServer/")
  }
