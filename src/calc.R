library(jsonlite)
library(geosphere)

calc_solution_leg <- function(zone, vehicle, facility, config, i) {
  # calculate the number of vehicles and resources to deliver in a
  # specific delivery zone from the hub within the delivery area
  # to the delivery points

  # distance if only 1 vehicle
  initial_distance <- calc_total_distance(zone, facility, 1, config)

  # number of resources considering capacity constraint
  m1 <- calculate_m1(vehicle, zone)
  # number of resources considering time constraint
  m2 <- calculate_m2(initial_distance, vehicle, zone, facility, config)
  # the number of resources is the max required
  m <- max(m1, m2)

  # total distance with the m vehicles
  total_distance <- calc_total_distance(zone, facility, m, config)
  total_time <- calculate_total_time(total_distance, vehicle, zone)

  solution <- NULL
  solution <- c(total_distance, total_time, m)

  return(solution)
}

#-----------------------------------------------------------------------------
# TOTAL DISTANCE
#-----------------------------------------------------------------------------
calc_total_distance <- function(zone, facility, m, config) {
  # calculated the total distance to deliver in the area as the sumation
  # from the depot to the centroid of the delivery area
  # and the distance within the delivery area
  # zone = name, delivery size (number of boxes), area (m2),
  #        latitude, longitude, number of delivery points
  # facility = (name, handling time, latitude, longitude)

  db_dhi <- calc_distance_direct_shipment(zone, facility, m, config)
  db_dhi <- db_dhi + calc_distance_distr_area(config[1], zone)

  return(as.double(db_dhi))
}

calc_distance_direct_shipment <- function(zone, facility, m, config) {
    # total direct distance from the branch/ mobile depot
    # to the first point of the delivery area
    #
    # zone = name, delivery size (number of boxes), area (m2),
    #        latitude, longitude, number of delivery points
    # facility = name, handling time, latitude, longitude

    if (config[7] == 1) {
        db_dhi <- calc_euclidean_distance(zone[4], zone[5],
                                         facility[3], facility[4])
    } else {
        db_dhi <- calc_geodesic_distance(zone[4], zone[5],
                                        facility[3], facility[4])
        db_dhi <- db_dhi * as.double(config[8])
    }

    # roundtrip distance
    db_dhi <- db_dhi * 2 * m

    return(db_dhi)
}

calc_distance_distr_area <- function(k, zone) {
    # calculated the distance to deliver to the delivery points within the
    # delivery zone according to Daganzo's approach
    # zone = name, delivery size (number of boxes), area (m2),
    #        latitude, longitude, number of delivery points

    # distance of delivering the nodes concentrated into the delivery zone

    daganzo_distance <- k * sqrt(as.double(zone[3])  * as.double(zone[6]))

    return(as.double(daganzo_distance))
}

calc_euclidean_distance <- function(lat1, lon1, lat2, lon2) {
    #calculates the distance between tow points.
    #Euclidean distance

    diff_lat <- as.double(lat1) - as.double(lat2)
    diff_lon <- as.double(lon1) - as.double(lon2)
    euclidian_distance <- sqrt(diff_lat ^ 2 + diff_lon ^ 2)

    return(euclidian_distance)
}

calc_geodesic_distance <- function(lat1, lon1, lat2, lon2) {
  #calculates the distance between tow points accoring to the haversine formula
  #by default in metres
  geodesic_distance <- distm(c(as.double(lon1), as.double(lat1)),
                             c(as.double(lon2), as.double(lat2)),
                             fun = distHaversine)
  g <- geodesic_distance[1] / 1000

  return(g)
}

#-----------------------------------------------------------------------------
# M1, M2
#-----------------------------------------------------------------------------
calculate_m1 <- function(vehicle, zone) {
  # calculate the number of vehicles required according to the capacity
  # of the vehicle and the distance within the delivery area
  # vehicle =  (name, capacity in parcels, speed (km/h), stop time (h))
  # zone = (name, delivery size in parcels, area (m2),
  #         latitude, longitude, number of delivery points)
  # (delivery size * number of deliveries)/ capacity of the vehicle

  db_m1 <- as.double(zone[2]) * as.double(zone[6]) / as.double(vehicle[2])

  dec <- db_m1 - as.integer(db_m1)
  if (dec > 0) {
    db_m1 <- as.integer(db_m1) + 1
  }
  else {
    db_m1 <- as.integer(db_m1)
  }

  return(db_m1)
}

calculate_m2 <- function(first_distance, vehicle, zone, facility, config) {
  # calculate the number of vehicles required according to the capacity
  # of the vehicle
  # and the distance within the delivery area
  # vehicle =  (name, capacity in parcels, speed (km/h), stop time (h))
  # zone = (name, delivery size in parcels, area (m2),
  #         latitude, longitude, number of delivery points)
  # facility = (name, handling time, latitude, longitude)

  db_m2 <- calculate_total_time(first_distance, vehicle, zone)

  # resources (people) = total time for delivering div by the time
  # available after reducing the time for preparing the vehicle in
  # the facility
  db_m2 <- db_m2 / (as.double(config[2]) - as.double(facility[2]))

  dec <- db_m2 - as.integer(db_m2)

  if (dec > 0) {
    db_m2 <- as.integer(db_m2) + 1
  } else {
    db_m2 <- as.integer(db_m2)
  }

  return(db_m2)
}

#-----------------------------------------------------------------------------
# TOTAL TIME
#-----------------------------------------------------------------------------
calculate_total_time <- function(distance, vehicle, zone) {
  # calculated the total time to deliver in the area as the sumation
  # from the depot to the centroid of the delivery area and the distance
  # within the delivery area
  # vehicle =  (name, capacity (Porto in boxes), speed (km/h), stop time (h))
  # zone = name, delivery size (number of boxes), area (m2),
  #        latitude, longitude, number of delivery points

  db_time <- (distance) / as.double(vehicle[3])
  db_time <- db_time + as.double(vehicle[4]) * as.double(zone[6])

  return(as.double(db_time))
}