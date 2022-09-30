#Script for calculating the area (m2) and centroid (latitude, longitude) of a polygone representing a delivery zone
#Input: zip file with shapefile
#Output: area
#CSR= Force EPSG = 4326 ==> WGS84
library(sp)
library(sf)
library(raster)
library(dplyr)
library(spData)
library(ggplot2)
library(ggmap)
library(geojsonio)


'--------------------------------------------------------------------------------------------------------------------------------------------------'
'obtain a zip file from open source url and unzip the geographic files in a temporary file '
'--------------------------------------------------------------------------------------------------------------------------------------------------'

Read_url_GeographicData <- function(str_url, file_dir) {
  
  
 # download.file(url = str_url, destfile = "./TEMP/temp.zip")
 #unzip(zipfile = "./TEMP/temp.zip", overwrite = T, exdir="./TEMP")#insta
  download.file(url = str_url, destfile =paste(file_dir,"/SHAPEFILE/shapefile.zip",sep=""))
  unzip(zipfile = paste(file_dir,"SHAPEFILE/shapefile.zip",sep=""), overwrite = T, exdir=paste(file_dir,"/SHAPEFILE",sep=""))#insta
}

'--------------------------------------------------------------------------------------------------------------------------------------------------'
'once the file is downloaded or available, it reads the shapefile str_file_name '
'--------------------------------------------------------------------------------------------------------------------------------------------------'

Read_area <- function(str_file_name) {
  'It reads the file str_file_name. A sapefile with geographic information of the delivery area and returns the area in square metres'
  
  list.of.packages <- c("sp","sf", "raster","dplyr","spData") 
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
 
  
  zone=st_read(dsn=str_file_name)
  print(class(zone))
  zone = st_transform(zone, crs = 4326)
  CSR = st_crs(zone)
  'print(CSR)'
  
  area=st_area(st_polygonize(zone))
  print(area)
  
  return (area)
}

Read_centroid <- function(str_file_name) {
  'It reads the file str_file_name. A sapefile with geographic information of the delivery area and returns the centorid'
  
  
  list.of.packages <- c("sp","sf", "raster","dplyr","spData","ggplot2", "ggmap") 
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
 
  
  zone=st_read(dsn=str_file_name)
  zone = st_transform(zone, crs = 4326)  
  CSR = st_crs(zone)

  
  centroid=st_centroid(st_polygonize(zone))

  return (centroid)
}



Read_zone_Lyon <- function() {
  # Check and install packages
  list.of.packages <- c("sp","sf", "raster","dplyr","spData","ggplot2", "ggmap", "geojsonio") 
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # file <- system.file("examples", "california.geojson", package = "geojsonio")
  
 
  p = geojsonio::geojson_read("Lyon/confluence_area.geojson", what = "sp", parse = TRUE)

  r = st_as_sf(p)
  area=st_area(r)
  print(area)
  
  centroid_lyon =st_centroid(r)
  print(centroid_lyon)
  
  plot(st_geometry(r), col = 'white', border = 'grey', axes = TRUE)
  plot(st_geometry(st_centroid(r)), pch = 3, col = 'red', add = TRUE)
  
  
  return (centroid_lyon)
}

Read_facilities_Lyon <- function() {
  # Check and install packages
  list.of.packages <- c("sp","sf", "raster","dplyr","spData","ggplot2", "ggmap", "geojsonio") 
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # file <- system.file("examples", "california.geojson", package = "geojsonio")
  
   p = geojsonio::geojson_read("Lyon/distribution_center.geojson", what = "sp", parse = TRUE)
  
  r = st_as_sf(p)
  print(r)
  plot(r, pch = 2, col = 'red', axes = TRUE)
 
  
  
  return (r)
}

Read_demand_Lyon <- function() {
  # Check and install packages
  list.of.packages <- c("sf", "raster","dplyr","spData","ggplot2", "ggmap", "geojsonio") 
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  
  # file <- system.file("examples", "california.geojson", package = "geojsonio")
  
 
  print(a)
  s = geojsonio::geojson_read("Lyon/demand.geojson", what = "sp", parse = TRUE)
  
  demand = st_as_sf(s)
  print(demand)
  plot(demand, add=TRUE)
  

  
  return (demand)
}
                        

  

