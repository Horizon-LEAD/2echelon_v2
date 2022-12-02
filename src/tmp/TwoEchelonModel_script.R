#Version:               1.1
#Date of creation:      17.05.2021
#Author:                Beatriz Royo
#Last Update:           17.06.2022
#Last modification:     Beatriz Royo
#Previous version:      1.0
#Changes:

#------------------------------------------------------------------------------
#Description: Script for calculating the number of resources and distance for 2 echelon networks (first leg, second leg)
#             or for just the second leg depending on the input data configuration
#input data:
#           path = string with the root folder where the model and folders are located
#           dfOutput = data.frame(
                      #'echelon' number of the leg {1:2}
                      # 'zone_name'=name of the zone of the leg echelon,
                      # 'zone_avg_size'= average size of the item deliver of the zone of the leg echelon,
                      # 'zone_area_km2'=square km of the delivery zone of the zone of the leg echelon,
                      # 'zone_total_services'=number of services to be delivered in zone_name of the zone of the leg echelon,
                      # 'zone_latitude'= coordinate x of some concentric point of zone_name of the zone of the leg echelon,
                      # 'zone_longitude'=coordinate y of some concentric point of zone_name of the zone of the leg echelon,
                      # 'facility_name' = name of the facility of the leg echelon,
                      # 'facility_handling_time' = handling time facility of the leg echelon,
                      # 'facility_latitude'= latitude of the facility of the leg echelon,
                      # 'facility_longitude'= longitude of the facility of the leg echelon,
                      # 'vehicle_name'= name of the vehicle of the leg echelon,
                      # 'vehicle_capacity'= capacity of the vehicle of the leg echelon,
                      # 'vehicle_velocity_km.s'= velocity of the vehicle of the leg echelon,
                      # 'vehicle_velocity_stop_time'= stop time of the vehicle of the leg echelon (h),
                      # 'total_distance_km' = total distance made by the vehicle of the leg echelon to fulfill the leg echelon (km),
                      # 'total_time_hours' = total time made by the vehicle of the leg echelon to fulfill the leg echelon (h),
                      # 'number_vehicles' = total distance made by the vehicle of the leg echelon to fulfill the leg echelon,

#------------------------------------------------------------------------------------------
# execution: README File
#----------------------------------------------------------------------------------------

library(jsonlite)

initialization <- function (vehicle1, facility1, vehicle2, facility2, config){


  facility1[2] = config[3] #handling time first facility
  facility2[2] = config[4] #handling time second facility
  vehicle1[4] = config[5] #stop time first echelon
  vehicle2[4] = config[6] #stop time second echelon
  #browser()
}


calculateSolutionTwoEchelon <- function(path){
  #calculate the number of resources per leg. If first leg not needed the input data for the area and the delivery
  #points must be zero
  #calculate the number of resources per leg. If first leg not needed the input data for the area and the delivery
  #points must be zero

  config = read_config(path)
  facility1 = read_facility(path,1, config[3])
  vehicle1 = read_vehicle(path,1,config[5])

  facility2 = read_facility(path,2,config[4])
  vehicle2 = read_vehicle(path,2,config[6])
  zone1=read_deliveryZone(path,1,T,facility2)
  zone2 = read_deliveryZone(path,2,T,NULL)
  #browser()

  #initialization (vehicle1, facility1, vehicle2, facility2, config)
  solutionFirstLeg = calculateSolutionLeg(zone1,vehicle1, facility1, config,1)
  solutionSecondLeg = calculateSolutionLeg(zone2, vehicle2, facility2, config,2)


  output=c(solutionFirstLeg, solutionSecondLeg)

  dfOutput = data.frame('echelon'=1:2,
                        'zone_name'=c(zone1[1],zone2[1]),
                        'zone_avg_size'=c(zone1[2],zone2[2]),
                        'zone_area_km2'=c(zone1[3],zone2[3]),
                        'zone_total_services'=c(zone1[6],zone2[6]),
                        'zone_latitude'=c(zone1[4],zone2[4]),
                        'zone_longitude'=c(zone1[5],zone2[5]),
                        'facility_name' = c(facility1[1],facility2[1]),
                        'facility_handling_time' = c(facility1[2],facility2[2]),
                        'facility_latitude'=c(facility1[3],facility2[3]),
                        'facility_longitude'=c(facility1[4],facility2[4]),
                        'vehicle_name'= c(vehicle1[1],vehicle2[1]),
                        'vehicle_capacity'= c(vehicle1[2],vehicle2[2]),
                        'vehicle_velocity_km.s'= c(vehicle1[3],vehicle2[3]),
                        'vehicle_velocity_stop_time'= c(vehicle1[4],vehicle2[4]),
                        'total_distance_km' = c(output[1],output[4]),
                        'total_time_hours' = c(output[2],output[5]),
                        'number_vehicles' = c(output[3], output[6]))


  return (dfOutput)
}

calculateSolutionOneEchelon <- function(path){
  #calculate the number of resources per leg. If first leg not needed the input data for the area and the delivery
  #points must be zero
  #browser()
  config = read_config(path)
  facility = read_facility(path,1,config[3])
  vehicle = read_vehicle(path,1,config[5])
  zone=read_deliveryZone(path,1,F,NULL)

  #initialization (vehicle, facility, NULL, NULL, config)

  output = calculateSolutionLeg(zone,vehicle, facility, config,1)


  dfOutput = data.frame('echelon'=1,
                        'zone_name'=c(zone[1]),
                        'zone_avg_size'=c(zone[2]),
                        'zone_area_km2'=c(zone[3]),
                        'zone_total_services'=c(zone[6]),
                        'zone_latitude'=c(zone[4]),
                        'zone_longitude'=c(zone[5]),
                        'facility_name' = c(facility[1]),
                        'facility_handling_time' = c(facility[2]),
                        'facility_latitude'=c(facility[3]),
                        'facility_longitude'=c(facility[4]),
                        'vehicle_name'= c(vehicle[1]),
                        'vehicle_capacity'= c(vehicle[2]),
                        'vehicle_velocicty_km.s'= c(vehicle[3]),
                        'vehicle_velocicty_stop_time'= c(vehicle[4]),
                        'total_distance_km' = c(output[1]),
                        'total_time_hours' = c(output[2]),
                        'number_vehicles' = c(output[3]))

  return (dfOutput)
}


calculateSolutionLeg<- function(zone,vehicle, facility, config, i) {
  #calculate the number of vehicles and resources to deliver in a specific delivery zone from the hub within the delivery area
  #to the delivery points

  initialDistance = calculateTotalDistance(zone, facility,1,config) #distance if only 1 vehicle

  m1 =calculateM1(vehicle,zone) #number of resources considering capacity constraint
  m2 = calculateM2(initialDistance, vehicle, zone, facility,config) #number of resources considering time constraint
  #browser()

  m =max(m1,m2) #the number of resources is the max required
  totalDistance = calculateTotalDistance(zone, facility,m,config) #total distance with the m vehicles
  totalTime = calculateTotalTime(totalDistance, vehicle, zone)

  'solution = list(vehicle, zone, facility, config, totalDistance, totalTime, m)'
  solution=NULL

  solution = c(totalDistance, totalTime, m)

  return (solution)
}


calculateTotalDistanceDirectShipment <- function(zone, facility, m, config) {
#total direct distance from the branch/ mobile depot to the first point of the delivery area
#zone = name, delivery size (number of boxes), area (m2), latitude, longitude, number of delivery points
#facility = name, handling time, latitude, longitude
  #db_dhi = calculateEuclideanDistance(zone[4], zone[5], facility[3], facility[4])
  # db_dhi = calculateGeodesicDistance(zone[4], zone[5], facility[3], facility[4])

    if(config[7]==1){
      print('Euclidean')
      db_dhi = calculateEuclideanDistance(zone[4], zone[5], facility[3], facility[4])
    }else{
      #print('haversine')
      db_dhi = calculateGeodesicDistance(zone[4], zone[5], facility[3], facility[4])*as.double(config[8])
    }


  db_dhi = db_dhi * 2 * m #roundtrip distance

  return (db_dhi)
}

calculateEuclideanDistance <- function(lat1, lon1, lat2,lon2) {
#calculates the distance between tow points.
#Euclidean distance

  EuclidianDistance = sqrt((as.double(lat1) - as.double(lat2)) ^ 2 + (as.double(lon1) - as.double(lon2)) ^ 2)
  #browser()

  return (EuclidianDistance)
}


calculateGeodesicDistance <- function(lat1, lon1, lat2,lon2) {
  #calculates the distance between tow points accoring to the haversine formula
  #by default in metres

  library(geosphere)
  GeodesicDistance= distm (c(as.double(lon1), as.double(lat1)), c(as.double(lon2), as.double(lat2)), fun = distHaversine)
  ##browser()

  g=GeodesicDistance[1]/1000

  return (g)
}

calculatelDistanceDistributionArea <- function(k, zone) {
#calculated the distance to deliver to the delivery points within the delivery zone according to Daganzo's approach
#zone = name, delivery size (number of boxes), area (m2), latitude, longitude, number of delivery points

DaganzoDistance = k * sqrt(as.double(zone[3])  * as.double(zone[6])) #distance of delivering the nodes concentrated into the delivery zone
return (as.double(DaganzoDistance))



}


calculateTotalDistance <- function(zone, facility,m, config) {
  #calculated the total distance to deliver in the area as the sumation from the depot to the centroid of the delivery area
  #and the distance within the delivery area
  #zone = name, delivery size (number of boxes), area (m2), latitude, longitude, number of delivery points
  #facility = (name, handling time, latitude, longitude)

  db_dhi = calculateTotalDistanceDirectShipment(zone, facility, m, config)
  db_dhi = db_dhi + calculatelDistanceDistributionArea(config[1], zone)
  return (as.double(db_dhi))


}


calculateTotalTime <- function(distance, vehicle, zone) {
  #calculated the total distance to deliver in the area as the sumation from the depot to the centroid of the delivery area
  #and the distance within the delivery area
  #vehicle =  (name, capacity (Porto in boxes), speed (km/h), stop time (h))
  #zone = name, delivery size (number of boxes), area (m2), latitude, longitude, number of delivery points


  db_time = (distance) / as.double(vehicle[3])
  db_time = db_time + as.double(vehicle[4]) * as.double(zone[6])
  #browser()

  return (as.double(db_time))


}

calculateM1<- function(vehicle, zone) {
  #calculate the number of vehicles required according to the capacity of the vehicle
  #and the distance within the delivery area
  #vehicle =  (name, capacity in parcels, speed (km/h), stop time (h))
  #zone = (name, delivery size in parcels, area (m2), latitude, longitude, number of delivery points)

  #(delivery size * number of deliveries)/ capacity of the vehicle
  db_m1 = as.double(zone[2])*as.double(zone[6]) / as.double(vehicle[2])

  dec = db_m1 - as.integer(db_m1)
  if(dec > 0){
    db_m1 = as.integer(db_m1)+1

  }
  else {
    db_m1 = as.integer(db_m1)

  }


  return (db_m1)


}

calculateM2<- function(firstDistance, vehicle, zone, facility, config) {
  #calculate the number of vehicles required according to the capacity of the vehicle
  #and the distance within the delivery area
  #vehicle =  (name, capacity in parcels, speed (km/h), stop time (h))
  #zone = (name, delivery size in parcels, area (m2), latitude, longitude, number of delivery points)
  #facility = (name, handling time, latitude, longitude)

  db_m2 = calculateTotalTime(firstDistance,vehicle,zone)

  #resources (people) = total time for delivering div by the time available after reducing the time for preparing the vehicle in the facility
  db_m2 = db_m2 / (as.double(config[2]) - as.double(facility[2]))

  dec = db_m2 - as.integer(db_m2)

  if(dec>0){
    db_m2 = as.integer(db_m2)+1

  }
  else {
    db_m2 = as.integer(db_m2)

  }

  return (db_m2)


}



