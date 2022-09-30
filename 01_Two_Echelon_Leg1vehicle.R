
#Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_Two_Echelon_Leg1vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Description: 
#     Script for executing scenarios.json:
#     direct shipments from the branch in San Fernando to the consumers using a non-electric vehicle defined in args[3]
#     it creates the inputs and the dependencies for  wrapping function that connects to the next model (COPERT)
#     args[1] = the location of the folder that contains the scripts, the INPUT, OUTPUT, SHAPEFILES folder to run the scenario
#     args[2] = the name of the vehicle of the leg 2
#     args[3] = the capacity of the vehicle of the leg 2 (same metric that the average service)
#     args[4] = the speed of the vehicle of the leg 2 (km/s)
#     
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#reading the parameters from the console
args= commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
#stop("One arguments need to be supplied", call.=FALSE)
  path_in = "C:/LEAD_MODELS/NEW/2echelon-main"
  vehicleName = "NV200,Electric,Cargo,Vehicle"
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




#predefined parameters
two_echelon_output_filename="output_two_echelon.json"                     #name of the output file with the results and all the information of the scenario

config = read_config(path_in)
facility1 = read_facility(path_in,1, config[3])
vehicle1 = read_vehicle(path_in,1,config[5])

vehicle1[1] = vehicleName
vehicle1[2] =  vehicleCapacity
vehicle1[3] =  vehicleVelocity
print(vehicle1)

facility2 = read_facility(path_in,2,config[4])
vehicle2 = read_vehicle(path_in,2,config[6])

zone1=read_deliveryZone(path_in,1,T,facility2)
zone2 = read_deliveryZone(path_in,2,T,NULL)
#browser()


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


write_outputJSON(path_in,dfOutput,two_echelon_output_filename)






