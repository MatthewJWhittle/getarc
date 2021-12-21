# First get the metadata of the layer as this is required for get_by_fids & type parsing functions
fire_metadata <- get_layer_details(endpoints$us_fire_occurrence)

# Define a table of fields that will be returned.
# Fields have been selected to represent the different types
fields <- tibble::tibble(name = c("OBJECTID", "FIRE_ID", "NODATA_THRESHOLD", "IG_DATE", "MAP_ID"))

out_fields <- paste0(fields$name, collapse =  ",")
# Get the feature data for parsing
fires <-
  get_by_fids(
    endpoint = endpoints$us_fire_occurrence,
    query = query_object(user_query = list(resultRecordCount = 10, outFields = out_fields)),
    return_n = 10,
    return_geometry = TRUE,
    my_token = NULL,
    layer_details = fire_metadata,
    out_fields = out_fields,
    object_ids = NULL
  )

# Add in the feature metadata to the fields table
fields <-
  fields %>%
  left_join(fire_metadata$fields %>% bind_rows()) %>%
  left_join(type_functions)

#First parse the datestimes (as is done in query layer)
fires_dttm <- parse_datetimes(fires, fire_metadata)

# Then convert all columns to character to test parsing
fires_chr <- mutate(fires_dttm, across(fields$name, .fns = as.character))

# Parse the data
fires_parsed <- parse_types(fires_chr, layer_details = fire_metadata)

# Define a vector of expected classes for each variable
expected_types <- list(OBJECTID = "integer", FIRE_ID = "character", NODATA_THRESHOLD = "numeric",
                       IG_DATE = c("POSIXct", "POSIXt"), MAP_ID = "integer", geometry = c("sfc_POINT",
                                                                                          "sfc"))

# Run tests
test_that("Parsing types works correctly",
          {
            expect_equal(map(fires_parsed, class), expected_types)
            expect_equal(all(
              map2_lgl(
                .x = st_drop_geometry(fires_parsed[fields$name]),
                .y = fields$type_assert_function,
                ~ .y(.x)
              )
            )
            , TRUE)
          })

# Trying to make it faster:...
#
# parse_types_2 <-
#   function(x, layer_details) {
#
#   # Make a table of the field types from the layer details
#   field_types <-
#     tibble::tibble(
#       name = purrr::map_chr(layer_details$fields, "name"),
#       type = purrr::map_chr(layer_details$fields, "type")
#     )
#
#   # Drop any columns not present in the dataframe
#   # Avoids errors when only returing asubset of columns
#   field_types <- dplyr::filter(field_types, .data$name %in% colnames(x))
#
#   # Join in the functions which parse each field type
#   field_types <- dplyr::left_join(field_types, type_functions, by = "type")
#
#   # Add in the timezone argument for datetime so that when dttms are parsed
#   # they are in the right timezone. This needs to be done once the data is downloaded
#   # Because that is when the expected TZ is known
#   is_dttm <- type_functions$type == "esriFieldTypeDate"
#   dttm_function <- type_functions$type_function[[which(is_dttm)]]
#   type_functions$type_function[[which(is_dttm)]] <- purrr::partial(dttm_function,
#                                                                    tz = layer_timezone(layer_details))
#
#   # function to check sf
#   is_sf <- function(x){any(c("sf", "sfc") %in% class(x))}
#   # only drop geom if sf
#   if (is_sf(x)) {
#     x_to_parse <- sf::st_drop_geometry(x)
#   } else{
#     x_to_parse <- x
#   }
#
#   correct_type <-
#     map2_lgl(.x = x_to_parse[field_types$name],
#              .y = field_types$type_assert_function,
#              ~ .y(.x))
#
#   if(all(correct_type)){return(x)}
#
#   field_types <- field_types[!correct_type,]
#
#   modifyList(x,
#              purrr::map2(
#                .x = x_to_parse[field_types$name],
#                .y = field_types$type_function,
#                ~ .y(.x)
#              ))
#   }
#
# debugonce(parse_types_2)
#
# microbenchmark::microbenchmark(
#   parse_types(x = fires_dttm, layer_details = fire_metadata),
#   parse_types_2(x = fires_dttm, layer_details = fire_metadata),
#   times = 100
# )
#
# require(microbenchmark)
# microbenchmark(class(letters) == "character",
#                is.character(letters))
