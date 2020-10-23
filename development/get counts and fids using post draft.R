devtools::load_all()
endpoint <- endpoints$english_counties

#data <- query_layer(endpoint, return_geometry = FALSE)

query = c(where = "cty19nm LIKE 'Devon'")
my_token = NULL
# get_feature_ids <-
#   function(endpoint, query = NULL, my_token = NULL){

    # # Check that returnsIdsOnly is not set to false in the query
    # query["returnIdsOnly"] <- "true"

    token <- parse_access_token(my_token)

    query <- modify_named_vector(default_query_parameters(),
                                 c(query, token = token, returnIdsOnly = "true"))

    query_url <- paste0(endpoint, "/query")

    # Download the data using a post query
    response <- httr::POST(query_url, body = as.list(query))

    # Fail if the response is not 200
    # Print an error message if the status code isn't 200
    assert_that(response$status_code == 200,
                message = httr::content(response, as = "text")
                )


    # Parse and return the content
    content <- httr::content(response, as = "text")
    object_ids <- jsonlite::fromJSON(content)
    return(object_ids$objectIds)

  #   # Map servers and Feature servers return data in a slightly different format
  #   # Need to parse the content, then check if it is a list, if not use fromJSON to extract a list
  #   if(is.list(content)){
  #     return(content)
  #   }else{
  #     return(jsonlite::fromJSON(content))
  #   }
  # }

    endpoint <- endpoints$sssi_england
    query = c(where = "SSSI_NAME LIKE 'Allen%'")
    my_token = NULL
#
# get_count <-
#   function(endpoint, query = NULL, my_token = NULL){

    # Parse the access token, returning NULL if one hasn't been passed in
    token <- parse_access_token(my_token)

    # Modify the standard query parameters and insert any that are required for the request
    query <- modify_named_vector(default_query_parameters(),
                                 c(query, token = token,
                                   returnCountOnly = "true"))

    # Define the query url by appending query to the endpoint url
    query_url <- paste0(endpoint, "/query")

    # Download the data using a post query
    response <- httr::POST(query_url,
                           # Body must be a list
                           body = as.list(query))

    # Fail if the response is not 200
    # Print an error message if the status code isn't 200
    assert_that(response$status_code == 200,
                message = httr::content(response, as = "text")
    )

    # Parse and return the content
    content <- httr::content(response, as = "text")
    count <- jsonlite::fromJSON(content)
     return(count$count)
  #   # Generate a query string including the access token if not null
  #   query_string <- query_string(query = query,  my_token = my_token)
  #
  #   query_url <- paste0(endpoint, "/query", query_string)
  #
  #   # Make the request and throw error if it failed
  #   response <- GET(query_url)
  #   stopifnot(response$status_code == 200)
  #
  #   # Parse the content and return a vecotr of featureIds
  #   content <- content(response)
  #   # Map servers and Feature servers return data in a slightly different format
  #   # Need to parse the content, then check if it is a list, if not use fromJSON to extract a list
  #   if(is.list(content)){
  #     return(content$count)
  #   }else{
  #     content <- jsonlite::fromJSON(content)
  #     return(content$count)
  #   }
  # # }
