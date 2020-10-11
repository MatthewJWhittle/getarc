devtools::load_all()
require(tidyverse)
require(sf)


bucks <-
  query_layer(
    endpoints$english_counties,
    crs = 27700,
    query = c(geometryPrecision = 2,
              where = "cty19nm LIKE 'Buckinghamshire'")
  )

x <- bucks

x_geom <- st_geometry(x)
plot(x_geom)
x_geom_simple <- simplify_sf_to_nchar(x_geom, char = 1000)



bucks_geojson <- geojsonsf::sf_geojson(st_geometry(bucks_simple))
st_as_text(st_geometry(bucks_simple))

json <- '{
  "rings" : [[[-97.06138,32.837],[-97.06133,32.836],[-97.06124,32.834],[-97.06127,32.832],
              [-97.06138,32.837]],[[-97.06326,32.759],[-97.06298,32.755],[-97.06153,32.749],
              [-97.06326,32.759]]],
  "spatialReference" : {"wkid" : 4326}
}
'
st_bbox(bucks)
json <- '{
  "rings" : [[[459111,177609],[505604,177609],[505604,242934],[459111,242934],[459111,177609]]],
  "spatialReference" : {"wkid" : 27700}
}
'

geojson <- st_as_sfc(st_bbox(bucks)) %>% geojsonsf::sfc_geojson()
crs <- 27700
rings <- str_remove_all(geojson, "\\{.+:|\\}")
json_2 <-
  paste0('{"rings" : ',
         rings,
         ",",
         '"spatialReference" : {"wkid" : ',
         crs,
         "}}")

query_layer(
  endpoints$ancient_woodland_england,
  return_geometry = FALSE,
  query = c(
    geometryType = "esriGeometryPolygon",
    geometry = json_2,
    spatialRel = "esriSpatialRelIntersects",
    inSR = 27700
  )
)



c(
  "esriGeometryPoint",
  "esriGeometryMultipoint",
  "esriGeometryPolyline",
  "esriGeometryPolygon",
  "esriGeometryEnvelope"
)

boundary <- st_as_sfc(st_bbox(x_geom_simple))

boundary_sfc <- st_geometry(boundary)

boundary_geojson <- geojsonsf::sfc_geojson(boundary_sfc)

crs <- st_crs(boundary_sfc)$epsg
rings <- str_remove_all(boundary_geojson, "\\{.+:|\\}")
json_2 <-
  paste0('{"rings" : ',
         rings,
         ",",
         '"spatialReference" : {"wkid" : ',
         crs,
         "}}")
sf_to_json <-
  function(x) {
    # Convert the boundary to an sfc objet
    x_sfc <- st_geometry(x)
    stopifnot(length(x_sfc) == 1)

    # First convert the boundary to geojson as this is closer to the required format
    x_geojson <- geojsonsf::sfc_geojson(x_sfc)

    # Extract the EPSG code
    crs <- st_crs(x_sfc)$epsg
    # Strip out everything outside the rings
    rings <- str_remove_all(x_geojson, "\\{.+:|\\}")
    # Format the geojson and return
    paste0('{"rings" : ',
           rings,
           ",",
           '"spatialReference" : {"wkid" : ',
           crs,
           "}}")
  }

sf_to_json(x_geom_simple)


esri_geometry_type <-
  function(x) {
    x_type <- as.character(sf::st_geometry_type(bucks))
    stopifnot(length(x_type) == 1)
    stopifnot(x_type %in% esri_sf_type_lookup$sf)
    dplyr::filter(esri_sf_type_lookup, sf == x_type)$esri
  }
bbox_to_query <-
  function(bbox) {
    stopifnot("bbox" %in% class(bbox))
    list(
      geometry = paste0(bbox, collapse = ","),
      geometryType = "esriGeometryEnvelope",
      spatialRel = "esriSpatialRelIntersects",
      inSR = st_crs(bbox)$epsg
    )
  }

x <- bucks

x_class <- class(x)
if("bbox" %in% x_class){
  bbox_to_query(x)
}else{
  list(
    geometry = sf_to_json(x),
    geometryType = esri_geometry_type(x),
    inSR = st_crs(x)$epsg,
    spatialRel = "esriSpatialRelIntersects"
  )
}


geometry_type <- esri_geometry_type(bucks)

query_layer(
  endpoints$ancient_woodland_england,
  return_geometry = FALSE,
  query = c(
    geometryType = "esriGeometryPolygon",
    geometry = boundary_to_json(st_simplify(bucks, dTolerance = 10000)),
    spatialRel = "esriSpatialRelIntersects",
    inSR = 27700
  )
)
esri_geometry_type <-
  function(x) {
    stopifnot(any(c("sf", "sfc") %in% class(x)))
    x_type <- as.character(sf::st_geometry_type(bucks))
    stopifnot(length(x_type) == 1)
    stopifnot(x_type %in% esri_sf_type_lookup$sf)
    dplyr::filter(esri_sf_type_lookup, sf == x_type)$esri
  }
# Alternative to stop if not
assert <- function (expr, error) {
  if (! expr) stop(error, call. = FALSE)
}

boundary_to_json <-
  function(boundary) {
    # Convert the boundary to an sfc objet
    boundary_sfc <- st_geometry(boundary)
    stopifnot(length(boundary_sfc) == 1)

    # First convert the boundary to geojson as this is closer to the required format
    boundary_geojson <- geojsonsf::sfc_geojson(boundary_sfc)

    # Extract the EPSG code
    crs <- st_crs(boundary_sfc)$epsg
    # Strip out everything outside the rings
    rings <- str_remove_all(boundary_geojson, "\\{.+:|\\}")
    # Format the geojson and return
    paste0('{"rings" : ',
           rings,
           ",",
           '"spatialReference" : {"wkid" : ',
           crs,
           "}}")
  }


spatial_query <-
  function(x, spatial_filter = "esriSpatialRelIntersects") {
    x_class <- class(x)
    stopifnot(any(c("sf", "sfc") %in% x_class))
    if("bbox" %in% x_class){
      list(
        geometry = paste0(bbox, collapse = ","),
        geometryType = "esriGeometryEnvelope",
        spatialRel = spatial_filter,
        inSR = st_crs(bbox)$epsg
      )
    }else{
      x <- st_geometry(x)
      stopifnot(length(x) == 1)
      x_simple <- simplify_sf_to_nchar(x, char = 1000)
      list(
        geometry = sf_to_json(x),
        geometryType = esri_geometry_type(x),
        spatialRel = spatial_filter,
        inSR = st_crs(x)$epsg
      )
    }
  }
spat_query <- spatial_query(bucks)
