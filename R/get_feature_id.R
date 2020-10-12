#' Get Feature IDs
#'
#' Get the feature IDs of a layer
#'
#' This function accepts an endpoint and a query and returns the feature_ids for an enpoint
#' @param endpoint the url endpoint of the service. See feature_server_endpoint and map_server_endpoint
#' @param query an optional query to include in the request
#' @param my_token an access token to be included when required
#' @return a vector of feature IDs
#' @import httr
#' @importFrom jsonlite fromJSON
#' @export get_feature_ids
get_feature_ids <-
  function(endpoint, query = NULL, my_token = NULL){

    # Check that returnsIdsOnly is not set to false in the query
    query["returnIdsOnly"] <- "true"

    # Check that a where clause was passed to query, if not add where 1=1 to return all features
    parameters <- names(query)
    if(!("where" %in% parameters)){
      query <- c("where" = "1=1", query)
    }

    # Generate a query string including the access token if not null
    query_string <- query_string(query = query,  my_token = my_token)

    query_url <- paste0(endpoint, "/query", query_string)

    # Make the request and throw error if it failed
    response <- GET(query_url)
    stopifnot(response$status_code == 200)

    # Parse the content and return a vecotr of featureIds
    content <- content(response)
    # Map servers and Feature servers return data in a slightly different format
    # Need to parse the content, then check if it is a list, if not use fromJSON to extract a list
    if(is.list(content)){
      return(content)
    }else{
      return(jsonlite::fromJSON(content))
    }
  }

#' Get Count
#'
#' This function accepts an endpoint and a query and returns the count of features matching the query. It is a useful and fast method of determining if the query will return any data.
#' @param endpoint the url endpoint of the service. See feature_server_endpoint and map_server_endpoint
#' @param query an optional query to include in the request
#' @param my_token an access token to be included when required
#' @return the count of features mathing the query
#' @import httr
#' @importFrom jsonlite fromJSON
#' @export get_count
get_count <-
  function(endpoint, query = NULL, my_token = NULL){

    # Check that returnsIdsOnly is not set to false in the query
    query["returnCountOnly"] <- "true"

    # Check that a where clause was passed to query, if not add where 1=1 to return all features
    parameters <- names(query)
    if(!("where" %in% parameters)){
      query <- c("where" = "1=1", query)
    }

    # Generate a query string including the access token if not null
    query_string <- query_string(query = query,  my_token = my_token)

    query_url <- paste0(endpoint, "/query", query_string)

    # Make the request and throw error if it failed
    response <- GET(query_url)
    stopifnot(response$status_code == 200)

    # Parse the content and return a vecotr of featureIds
    content <- content(response)
    # Map servers and Feature servers return data in a slightly different format
    # Need to parse the content, then check if it is a list, if not use fromJSON to extract a list
    if(is.list(content)){
    return(content$count)
    }else{
      content <- jsonlite::fromJSON(content)
      return(content$count)
    }
  }
