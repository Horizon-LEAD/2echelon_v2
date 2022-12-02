#---------------------------------------------------------
# I/O functions to read and write the inputs of the 2Echelon
# model and connect with the CO2 models
#------------------------------------------------------------
library(stringr)
library(jsonlite)

read_config <- function(path) {
  #-----------------------------------------------------------
  # Read default parameters from config
  #----------------------------------------------------------
  fdconfig <- read.csv(path, header = TRUE, ";")

  config_ui <- as.matrix(fdconfig, nrow = 2, ncol = 8, byrow = TRUE)
  config_ui

  k <- config_ui[1, 1]
  workshift <- config_ui[1, 2]
  handling_time_first_echelon <- config_ui[1, 3]
  handling_time_second_echelon <- config_ui[1, 4]
  stop_time_first_echelon <- config_ui[1, 5]
  stop_time_second_echelon <- config_ui[1, 6]
  distance_type <- config_ui[1, 7]
  haversine_calibration <- config_ui[1, 8]
  config <- c(k, workshift, handling_time_first_echelon,
              handling_time_second_echelon, stop_time_first_echelon,
              stop_time_second_echelon, distance_type,
              haversine_calibration)

  return(config)
}

read_facility <- function(path, leg, handling_time) {
  #---------------------------------------------------------------
  # Read data of facilities to serve the consumers.
  # First row of the file_facilities (.csv) with the information
  # of the facilities
  #---------------------------------------------------------------
  fd_facilities <- read.csv(path, header = FALSE, ";")

  #FacilityUI = Information in the file
  #(Name Address Number City ZipCode Latitude Longitude
  # HandlingTime(minutes) StartHour EndHour)
  facility_ui <- as.matrix(fd_facilities, nrow = 3, ncol = 10, byrow = TRUE)

  #Model data input : facility = (name, handling time(h), latitude, longitude)'
  #facility first leg in San Fernando = origin of the route
  facility <- c(facility_ui[leg, 1], handling_time,
                as.double(facility_ui[leg, 6]), as.double(facility_ui[leg, 7]))

  return(facility)
}

read_vehicle <- function(path, leg, stop_time) {
  #--------------------------------------------------------------------
  # Read data of the vehicles to serve the consumer.
  # First row of the #document (.csv) contains the information for the
  # first leg and the the second row for the second leg.
  # i = leg
  #--------------------------------------------------------------------
  fd_vehicles <- read.csv(path, header = FALSE, ";")
  vehicles_ui <- as.matrix(fd_vehicles, nrow = 3, ncol = 7, byrow = TRUE)

  #vehicle =  (name, capacity (Porto in boxes), speed (km/h), stop time (h))
  vehicle <- c(vehicles_ui[leg, 1], vehicles_ui[leg, 2],
               vehicles_ui[leg, 6], stop_time)

  return(vehicle)
}

read_services <- function(path) {
  #---------------------------------------------------------------------------
  # read the file services and return the number of delveries and the average
  # size if the file exists
  #---------------------------------------------------------------------------
  zone_services_fields <- c(0, 0)

  file_services <- paste(path, sep = "")
  fd <- read.csv(file_services, header = F, "\t")
  zone_avg_order_size <- (mean(na.omit(fd$V20)) + mean(na.omit(fd$V19))) / 2
  zone_no_orders <- nrow(fd)
  # zone_aggregatedOrders_size <- sum(na.omit(fd$V20)) + sum(na.omit(fd$V19))
  zone_services_fields <- c(zone_avg_order_size, zone_no_orders)

  print(zone_services_fields[1])

  return(zone_services_fields)
}

read_services_error_handling <- function(code) {
  #---------------------------------------------------------------------------
  # most cases the file with the services will not exist.
  # this code is for handling with the exception.
  #---------------------------------------------------------------------------
  print("error handling")

  zone_services_fields <- c(0, 0)

  zone_services_fields <- tryCatch(code,
           error = function(c) {
             message("error")
             zone_services_fields <- c(0, 0)
             },
           warning = function(c) {
             message("warning")
             zone_services_fields <- c(0, 0)
             },
           message = function(c) {
             message("message")
             zone_services_fields <- c(0, 0)
           }
  )

  return(zone_services_fields)
}

read_delivery_zone <- function(path, file_services, leg,
                               is_two_echelon, facility) {
  #---------------------------------------------------------------------------
  # read the data of the delivery zone
  #---------------------------------------------------------------------------

  # read zones
  file_zones <- paste(path, sep = "")
  fd_zones <- read.csv(file_zones, header = T, ";")
  zones_ui <- as.matrix(fd_zones, nrow = 2, ncol = 9, byrow = TRUE)

  # number of services and average size will be read from different sources
  # depending on if the services.csv is available
  fd_services <- read_services_error_handling(read_services(file_services))
  if (fd_services[1] == 0) {
    zone_avg_order_size <- zones_ui[1, 10]
    zone_no_orders <- zones_ui[1, 11]
  } else {
    zone_avg_order_size <- fd_services[1]
    zone_no_orders <- fd_services[2]
  }

  if (is_two_echelon && leg == 1) {
    total_size <- as.double(zone_avg_order_size) * strtoi(zone_no_orders)
    zone <- c(1, total_size, 0, facility[3], facility[4], 1)
  } else {
    zone_aux <- c(zones_ui[1, 3], zones_ui[1, 4],
                  zones_ui[1, 5], zones_ui[1, 6])
    print(strtoi(zone_aux[1]))

    if (strtoi(zone_aux[1]) == 1 || strtoi(zone_aux[3] == 1)) {
      if (strtoi(zone_aux[1]) == 1) { # the case of Madrid
        str_url <- zone_aux[2]
        str_file_name <- paste(dirname(path), zone_aux[4], sep = "/")
        read_geodata_url(str_url, dirname(path))
      } else {
        if (strtoi(zone_aux[3]) == 1) {
          str_file_name <- paste(dirname(path), zone_aux[4], sep = "/")
        }
      }

      zone_area <- read_area(str_file_name)
      zone_area <- zone_area / 1000000
      zone_centroid <- read_centroid(str_file_name)
      zone_centroid_geometry <- st_geometry(zone_centroid)
      zone_coordinates_centroid <- st_coordinates(zone_centroid_geometry)
      zone_centroid_x <- zone_coordinates_centroid[2]
      zone_centroid_y <- zone_coordinates_centroid[1]
    } else {
      zone_area <- zones_ui[1, 7]
      zone_centroid_x <- zones_ui[1, 8]
      zone_centroid_y <- zones_ui[1, 9]
    }

    zone <- c(leg, zone_avg_order_size, zone_area,
              zone_centroid_x, zone_centroid_y,
              zone_no_orders)
  }

  return(zone)
}

write_json_out <- function(df, fpath) {
  #---------------------------------------------------------------------------
  #write the output in the output file (.json); only the outputs
  #---------------------------------------------------------------------------
  df_json <- toJSON(df, pretty = TRUE)
  fd <- write(df_json, fpath)

  return(fd)
}