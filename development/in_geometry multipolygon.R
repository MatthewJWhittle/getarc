devtools::load_all()

two_awi<-
  query_layer(endpoint = endpoints$ancient_woodland_england,
            query = c(resultRecordCount = 2, geometryPrecision = 1),
            crs = 27700)

require(sf)
geometry <- two_awi %>% st_centroid() %>% st_buffer(1000) %>% st_union()

# Does not work for multi-polygons:
query_layer(endpoint = endpoints$ancient_woodland_england,
            in_geometry = geometry,
            crs = 27700)



