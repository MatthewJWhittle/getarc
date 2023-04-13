devtools::load_all()

#query_layer(endpoint = endpoints$ancient_woodland_england, return_n = 2)
query_url <- "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Ancient_Woodland_England/FeatureServer/0/query"
query <-
  list(
    returnIdsOnly = "false",
    outFields = "*",
    where = "1=1",
    returnCountOnly = "false",
    f = "json",
    outSR = 4326,
    returnGeometry = "true",
    resultRecordCount = 1000
  )


# Benchmark parsing

# Add the token into the query
query <- utils::modifyList(query, list(token = parse_access_token(NULL)), keep.null = FALSE)
# Request the data using POST
response <- httr::POST(url = query_url, body = query)


microbenchmark::microbenchmark(parse_rjson(response),
                               RcppSimdJson::fparse(json = response$content),
                               times = 100)
parsed <- RcppSimdJson::fparse(json = response$content)

str(parsed$features)
