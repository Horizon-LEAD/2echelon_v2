
#Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_One_Echelon_vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Description: 
#     Script for executing scenarios.json:
#     direct shipments from the branch in San Fernando to the consumers using a non-electric vehicle defined in args[3]
#     it creates the inputs and the dependencies for  wrapping function that connects to the next model (COPERT)
#     args[1] = the location of the folder that contains the scripts, the INPUT, OUTPUT, SHAPEFILES folder to run the scenario
#     args[2] = the name of the vehicle
#     args[3] = the capacity of the vehicle (same metric that the average service)
#     args[4] = the speed of the vehicle (km/s)
#     
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#reading the parameters from the console
args= commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
#stop("One arguments need to be supplied", call.=FALSE)
  path_in = "C:/LEAD_MODELS/NEW/2echelon-main"
  vehicleName = "Light Commercial Vehicles,Diesel,N1-III,Euro 6 a/b/c"
  vehicleCapacity=161
  vehicleVelocity=45
  
 } else if (length(args)==4) {
#   # default output file
   print("hola")
   path_in =args[1]
   vehicleName = args[2]
   vehicleCapacity=args[3]
   vehicleVelocity=args[4]

}

#sourcing the libraries
setwd(path_in)
source("TwoEchelonModel_script.R")
source("TwoEchelonModel_IO.R")
source("Shapefile_to_Zone.R")

#predefined parameters
two_echelon_output_filename="output_two_echelon.json"                     #name of the output file with the results and all the information of the scenario


#read file with the scenarios

config = read_config(path_in)
facility = read_facility(path_in,1,config[3])
vehicle = read_vehicle(path_in,1,config[5])
#vehicle =  (name, capacity (Porto in boxes), speed (km/h), stop time (h))
vehicle[1] = vehicleName
vehicle[2] =  vehicleCapacity
vehicle[3] =  vehicleVelocity
print(vehicle)
zone=read_deliveryZone(path_in,1,F,NULL)

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


write_outputJSON(path_in,dfOutput,two_echelon_output_filename)






