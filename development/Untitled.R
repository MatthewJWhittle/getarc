devtools::load_all()


query_layer(endpoints$gb_postcodes,
            return_geometry = FALSE)



# my_token <- get_token()


profvis::profvis( {query_layer(endpoint = endpoints$english_counties,
                               query = c(geometryPrecision = 2
                               ))})

counties <-
  query_layer(endpoint = endpoints$english_counties,
              query = c(geometryPrecision = 2
                        ))


# debugonce(query_layer)
query_layer(
  endpoints$gb_wood_pasture_parkland,
  in_geometry = counties$geometry[1],
  return_geometry = FALSE
)
wood_pasture_by_county <-
  map(
  .x = seq_along(counties$geometry)[1:3],
  ~ query_layer(
    endpoints$gb_wood_pasture_parkland,
    in_geometry = counties$geometry[.x],
    return_geometry = FALSE
  )
)


query_layer(endpoint = endpoints$english_counties,
            query = c(geometryPrecision = 2,
                      where = "cty19nm LIKE 'Xa'"
            ))


query_layer(endpoints$gb_postcodes,
            return_geometry = FALSE)
