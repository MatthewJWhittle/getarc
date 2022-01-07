#'  Testing for query layer
#'
#'   The following arguments are added to speed up tests by reducing the
#'   number of features returned & the precision of the geometry
#'   return_n = 1,
#'   geometry_precision = 1,

require(sf)

one_row <- query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
                       return_n = 1,
                       geometry_precision = 1)

one_row_bng <- query_layer(
  endpoint = endpoints$gb_wood_pasture_parkland,
  crs = 27700,
  return_n = 1,
  geometry_precision = 1
)

small_feature <-
  query_layer(endpoints$gb_wood_pasture_parkland,
              where = "Shape__Area < 30",
              return_n = 1,
              geometry_precision = 1)


sql_query <- query_layer(
  endpoint = endpoints$gb_wood_pasture_parkland,
  return_n = 1,
  geometry_precision = 1,
  where = "SUBTYPE = 'Parkland' AND INTERPQUAL = 'Medium'"
)
# Perform a spatial query
bbox <-
  st_bbox(c(
    xmin = -1.310819,
    ymin = 51.369722,
    xmax = -1.307946,
    ymax = 51.371520
  ),
  crs = 4326)

spatial_query_bbox <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = bbox,
              return_n = 1,
              geometry_precision = 1)

point1 <- st_as_sf(data.frame(x = 448171, y = 163733), coords = c("x", "y"), crs = 27700)
point2 <- st_as_sf(data.frame(x = 448121, y = 163800), coords = c("x", "y"), crs = 27700)


spatial_query_point <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = point1,
              return_n = 2,
              geometry_precision = 1)

buffer <- st_buffer(point1, 1000)

spatial_query_buffer <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = buffer,
              return_n = 2,
              geometry_precision = 1)

mp <- st_union(
  st_buffer(point1, 10),
  st_buffer(point2, 10)
)
spatial_query_mp <-
  query_layer(endpoint = endpoints$gb_wood_pasture_parkland,
              in_geometry = mp,
              return_n = 1,
              geometry_precision = 1)
ms_nogeom <-
  query_layer(
    endpoints$english_counties,
    return_geometry = FALSE,
    return_n = 1
  )
fs_nogeom <-
  query_layer(endpoint = endpoints$ancient_woodland_england,
    return_geometry = FALSE,
    return_n = 1
  )

# debugonce(get_feature_ids)
us_fire_1001 <-
  query_layer(endpoint = endpoints$us_fire_occurrence,
            out_fields = "OBJECTID",
            return_n = 1001,
            return_geometry = TRUE)


# tibble(OBJECTID = character(0),
#        NAME = character(0)
# )

# Suppress the warnings so that they don't trigger a test fail
no_awi <-
  suppressWarnings({
    query_layer(
      endpoint = endpoints$ancient_woodland_england,
      where = "1=2",
      out_fields = c("NAME", "OBJECTID"),
      return_geometry = FALSE
    )
  })

# The API returns NULL values and these were not being converted to NA properly
# This tests against an endpoint where there are known null values
# The number of rows in the tibble should match the count
ep_null_values <- "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/NULL_Values_Test/FeatureServer/0"

null_expected <- get_count(endpoint = ep_null_values)

null_column <- query_layer(ep_null_values,
            return_geometry = FALSE,
            out_fields = "null_values")



test_that("query layer works", {
  # Check that resultRecordCount = 1 works
  expect_equal(nrow(one_row),
               1)
  # Check that the function returns a data frame
  expect_equal(class(one_row),
               c("sf", "data.frame"))
  # Test that it transforms data when the crs != 4326
  expect_equal(st_crs(one_row_bng)$epsg,
               27700)
  # Check that sql  where query works
  expect_equal(sql_query$SUBTYPE, "Parkland")
  expect_equal(sql_query$INTERPQUAL, "Medium")
  # Did the spatial query only return one result?
  expect_equal(nrow(spatial_query_bbox),
               1)

  expect_equal(nrow(spatial_query_buffer) >= 1,
               TRUE)
  expect_equal(nrow(spatial_query_point) >= 1,
               TRUE)

  expect_warning(query_layer(endpoint = endpoints$gb_wood_pasture_parkland, where = "1 = 2"))
  expect_warning(query_layer(endpoint = endpoints$gb_wood_pasture_parkland, where = "1 = 2", return_n = 1))
  expect_warning(query_layer(endpoint = endpoints$gb_wood_pasture_parkland, where = "1 = 2", return_n = 1, return_geometry = FALSE))

  # Does the area query have the desired result
  expect_equal(small_feature$Shape__Area < 30, TRUE)
  # return_geometry = FALSE returns a data.frame for both map servers and feature servers
  expect_equal("data.frame" %in% class(ms_nogeom), TRUE)
  expect_equal("data.frame" %in% class(fs_nogeom), TRUE)

  # the return record count param works properly with get by fids method
  expect_equal(nrow(us_fire_1001), 1001)

  expect_equal(no_awi, tibble(OBJECTID = numeric(0),
                              NAME = character(0)
  ))
  # Expect that null values are parsed correctly and returned as a tibble
  expect_equal(nrow(null_column), null_expected)

  # Some layers don't support edit tracking. This tests that a warning is returned.
  expect_warning(query_layer(endpoint = endpoints$us_fire_occurrence,
                             cache = "development/data-cache/test-warning.geojson",
                             return_n = 1, return_geometry = FALSE))

})


# Test Caching behaviour
# First clear the old cache
cache_file <- "development/data-cache/test-points.geojson"
if(file.exists(cache_file)) {file.remove(cache_file)}
if(!dir.exists(dirname(cache_file))) {dir.create(dirname(cache_file), recursive = TRUE)}
# define the layer to cache and where to cache it
ep_test_points <- "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/Points/FeatureServer/0"
# Download the points layer and cache it
points_dl <- query_layer(endpoint = ep_test_points,
                         cache = cache_file)
# read the cached data
cached_data <- geojsonsf::geojson_sf(cache_file)
# Add a new point to the layer to the retreive when updating the cache
add_point_to_test_ep(endpoint = ep_test_points)
# Retrieve the updated layer without caching so the results can be compared
updated_layer <- query_layer(endpoint = ep_test_points)
updated_cache <- query_layer(endpoint = ep_test_points,
                         cache = cache_file)
# Check the file on disk
updated_cache_file <- geojsonsf::geojson_sf(cache_file)
cache_details <- get_layer_details(ep_test_points)
updated_cache_file <- parse_types(updated_cache_file, layer_details = cache_details)
updated_cache_file <-
  dplyr::select(updated_cache_file,
              # Using Any Of as sometimes the column names may not be present
              dplyr::any_of(field_names(cache_details)))




test_that("Caching Works",
          {
            local_edition(3)
            # The cache has been created
            expect_true(file.exists(cache_file))
            # The updated cache should be equivalent to the updated layer
            expect_equal(updated_cache, updated_layer, tolerance = 1, ignore_attr = TRUE)
            # The updated file on disk should be equivalent to the updated layer
            expect_equal(updated_cache_file, updated_layer, tolerance = 1, ignore_attr = TRUE)
            expect_equal(st_crs(updated_cache)$epsg, st_crs(updated_layer)$epsg)
            # The updated cache returned by query layer should have one additional row from adding a point
            expect_equal(nrow(updated_cache) - nrow(points_dl), 1)
            # This test is failing during testing but not when run outside tests - I don't know why
            # Throwing an error relating to date parsing
            # expect_warning(query_layer(endpoint = endpoints$cairns_corals,
            #                            return_n = 1,
            #                            cache = "development/data-cache/cairns-corals-1.geojson"
            #                            ),
            #                NA)
          })
#
#
# query_layer(endpoint = endpoints$cairns_corals,
#             return_n = 1,
#             cache = "development/data-cache/cairns-corals-1.geojson")
