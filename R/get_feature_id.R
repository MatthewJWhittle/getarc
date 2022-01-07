#' Get Feature IDs
#'
#' Get the feature IDs of a layer
#'
#' This function accepts an endpoint and a query and returns the feature_ids for an enpoint
#' @param endpoint the url endpoint of the service. See feature_server_endpoint and map_server_endpoint
#' @param query an optional query to include in the request
#' @param my_token an access token to be included when required
#' @return a list of feature IDs & the feature ID field
#' @importFrom httr POST
#' @importFrom httr content
#' @importFrom rjson fromJSON
#' @export get_feature_ids
#' @importFrom utils modifyList
get_feature_ids <-
  function(endpoint, query = list(), my_token = NULL){

    query <- query_object(default = default_query_parameters(),
                          user_query = query,
                          my_token = my_token,
                          mandatory = list(returnIdsOnly = "true",
                                           f = "json")
                          )

    # Get the request number of records to return and drop the param from the query
    # This can then be used to limit the number of FIDs returned by the function
    return_count <-  as.numeric(query[names(query) == "resultRecordCount"])
    query <- query[names(query) != "resultRecordCount"]

    query_url <- paste0(endpoint, "/query")

    # Download the data using a post query
    response <- httr::POST(query_url, body = query)

    # Fail if the response is not 200
    # Print an error message if the status code isn't 200
    assert_that(response$status_code == 200,
                message = httr::content(response, as = "text")
    )


    # Parse and return the content
    object_ids <- RcppSimdJson::fparse(response$content, max_simplify_lvl = "list")
    # cut down the object ids vector if a returnRecordCount has been sent & the
    # return count is less than the object_ids vector length
    # This enables us to work around the issue with the feature service not returning
    # feature IDs restricted by the returnRecordCount parameter
    # It may make the process slower for feature layers with many records
    # Need to think of a weay to get around this
    if(length(return_count) > 0 && length(object_ids$objectIds) > return_count){
      object_ids$objectIds <- object_ids$objectIds[c(1:return_count)]
    }

    # If the number of object IDs exceeds 100000 and a where_in query is used then paste0 functino will send number in scientific notation
    # to avoid this I'm going to assert that the data type is an integer
    object_ids$objectIds <- as.integer(object_ids$objectIds)

    return(object_ids)
  }
#' Get Count
#'
#' This function accepts an endpoint and a query and returns the count of features matching the query. It is a useful and fast method of determining if the query will return any data.
#' @param endpoint the url endpoint of the service. See feature_server_endpoint and map_server_endpoint
#' @param query an optional query to include in the request
#' @param my_token an access token to be included when required
#' @return the count of features mathing the query
#' @importFrom httr POST
#' @importFrom httr content
#' @importFrom rjson fromJSON
#' @export get_count
get_count <-
  function(endpoint, query = list(), my_token = NULL){

    query <- query_object(default = default_query_parameters(),
                          user_query = query,
                          my_token = my_token,
                          mandatory = list(returnCountOnly = "true", f = "json")
    )


    query_url <- paste0(endpoint, "/query")

    # Download the data using a post query
    response <- httr::POST(query_url, body = as.list(query))

    # Fail if the response is not 200
    # Print an error message if the status code isn't 200
    assert_that(response$status_code == 200,
                message = httr::content(response, as = "text")
    )


    # Parse and return the content
    count <- RcppSimdJson::fparse(response$content, max_simplify_lvl = "list")

    return(count$count)

  }
