# Script for calculating the area (m2) and centroid (latitude, longitude)
# of a polygone representing a delivery zone
# Input: zip file with shapefile
# Output: area
# CSR= Force EPSG = 4326 ==> WGS84

library(sp)
library(sf)
library(raster)
library(dplyr)
library(spData)
library(ggplot2)
library(ggmap)
library(geojsonio)


read_geodata_url <- function(str_url, file_dir) {
  download.file(url = str_url,
                destfile = paste(file_dir, "/shapefile.zip", sep = ""))
  unzip(zipfile = paste(file_dir, "/shapefile.zip", sep = ""),
        overwrite = TRUE,
        exdir = file_dir)
}

#' Reads area from shape file
#'
#' once the file is downloaded or available, reads the shapefile str_file_name
#' that contains georgaphic information of the delivery area and returns the
#' area size in square metres.
#'
#' list.of.packages <- c("sp", "sf", "raster", "dplyr", "spData")
#'  new.packages <- list.of.packages[
#'    !(list.of.packages %in% installed.packages()[,"Package"])
#'  ]
#'  if(length(new.packages)) install.packages(new.packages)
read_area <- function(str_file_name) {
  zone <- sf::st_read(dsn = str_file_name)
  print(class(zone))
  zone <- sf::st_transform(zone, crs = 4326)
  # csr <- sf::st_crs(zone)

  area <- sf::st_area(sf::st_polygonize(zone))
  print(area)

  return(area)
}

#' Reads a shapefile and returns the centroid location
#'
#' As input a shapefile with geographic information of the delivery area is
#' given. Returns the centroid of the area'
#'
#' list.of.packages <- c("sp", "sf", "raster", "dplyr", "spData",
#'                        "ggplot2", "ggmap")
#'  new.packages <- list.of.packages[
#'    !(list.of.packages %in% installed.packages()[, "Package"])
#'  ]
#'  if (length(new.packages)) install.packages(new.packages)
read_centroid <- function(str_file_name) {
  zone <- sf::st_read(dsn = str_file_name)
  zone <- sf::st_transform(zone, crs = 4326)
  # csr <- sf::st_crs(zone)
  centroid <- sf::st_centroid(sf::st_polygonize(zone))

  return(centroid)
}


#' Reads geojson data for Lyon
#'
#' list.of.packages <- c("sp", "sf", "raster", "dplyr", "spData",
#'                        "ggplot2", "ggmap", "geojsonio")
#'  new.packages <- list.of.packages[
#'    !(list.of.packages %in% installed.packages()[, "Package"])
#'  ]
#'  if (length(new.packages)) install.packages(new.packages)
read_zone_lyon <- function() {
  # file <- system.file("examples", "california.geojson",
  #                     package = "geojsonio")

  p <- geojsonio::geojson_read("Lyon/confluence_area.geojson",
                              what = "sp", parse = TRUE)

  r <- sf::st_as_sf(p)
  area <- sf::st_area(r)
  print(area)

  centroid_lyon <- sf::st_centroid(r)
  print(centroid_lyon)

  plot(sf::st_geometry(r), col = "white", border = "grey", axes = TRUE)
  plot(sf::st_geometry(sf::st_centroid(r)), pch = 3, col = "red", add = TRUE)

  return(centroid_lyon)
}

#' Reads facilities for Lyon based on geojson data
#'
#' list.of.packages <- c("sp", "sf", "raster", "dplyr", "spData",
#'                        "ggplot2", "ggmap", "geojsonio")
#'  new.packages <- list.of.packages[
#'    !(list.of.packages %in% installed.packages()[, "Package"])
#'  ]
#'  if (length(new.packages)) install.packages(new.packages)
read_facilities_lyon <- function() {
  # file <- system.file("examples", "california.geojson",
  #                     package = "geojsonio")

   p <- geojsonio::geojson_read("Lyon/distribution_center.geojson",
                               what = "sp", parse = TRUE)

  r <- sf::st_as_sf(p)
  print(r)
  plot(r, pch = 2, col = "red", axes = TRUE)

  return(r)
}

#' Reads Lyon's demand based on geojson data
#'
#' list.of.packages <- c("sp", "sf", "raster", "dplyr", "spData",
#'                        "ggplot2", "ggmap", "geojsonio")
#'  new.packages <- list.of.packages[
#'    !(list.of.packages %in% installed.packages()[, "Package"])
#'  ]
#'  if (length(new.packages)) install.packages(new.packages)
read_demand_lyon <- function() {
  # file <- system.file("examples", "california.geojson",
  #                     package = "geojsonio")

  s <- geojsonio::geojson_read("Lyon/demand.geojson", what = "sp", parse = TRUE)

  demand <- sf::st_as_sf(s)
  print(demand)
  plot(demand, add = TRUE)

  return(demand)
}
