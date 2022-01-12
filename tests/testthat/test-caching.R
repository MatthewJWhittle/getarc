init_config()
start_cache <- cache_dir()
temp_dir <- tempdir()
set_cache_directory(directory = temp_dir, create = TRUE)
changed_cache <- cache_dir()
set_cache_directory(start_cache)
test_that("setting cache path works", {
  expect_equal(changed_cache, temp_dir)
  expect_error(set_cache_directory("no-exist", create = FALSE))
})
test_that("constructing Cache Paths works",
          {
            expect_equal(construct_cache_path(endpoint = endpoints$cairns_corals),
                         paste0(cache_dir(),
                                "services3_arcgis_com/fp1tibNcN9mbExhG/arcgis/Cairns_2004_corals/FeatureServer/0-getarc-cache.geojson")
                         )
          })
