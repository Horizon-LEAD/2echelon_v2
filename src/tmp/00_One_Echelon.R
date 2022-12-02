# Rscript C:/LEAD_MODELS/NEW/2echelon-main/00_One_Echelon.R
#   C:/LEAD_MODELS/NEW/2echelon-main/
#-----------------------------------------------------------------------------
#Description:
#     Script for executing scenarios.json:
#     direct shipments from the branch in San Fernando to the consumers using
#     a non-electric vehicle defined in args[3]
#     it creates the inputs and the dependencies for  wrapping function that
#     connects to the next model (COPERT)
#     args[1] = the location of the folder that contains the scripts, the
#     INPUT, OUTPUT, SHAPEFILES folder to run the scenario
#-----------------------------------------------------------------------------

# reading the parameters from the console
args = commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
    # stop("One arguments need to be supplied", call.=FALSE)
    path_in = "C:/LEAD_MODELS/NEW/GITHUB_220930/2echelon-main"

 } else if (length(args) == 1) {
#   # default output file
   print("hola")
   path_in = args[1]

}

# sourcing the libraries
# setwd(path_in)
# find directory of the script and source deps
cli_args <- commandArgs(trailingOnly = FALSE)
script_name <- sub("--file=", "", cli_args[grep("--file=", cli_args)])
script_dirname <- dirname(script_name)

source(file.path(script_dirname, "TwoEchelonModel_script.R"))
source(file.path(script_dirname, "TwoEchelonModel_IO.R"))
source(file.path(script_dirname, "Shapefile_to_Zone.R"))

#predefined parameters
# name of the output file with the results and all the information
# of the scenario
two_echelon_output_filename = "output_two_echelon.json"


#read file with the scenarios

config = read_config(path_in)
facility = read_facility(path_in, 1, config[3])
vehicle = read_vehicle(path_in, 1, config[5])

zone = read_deliveryZone(path_in, 1, F, NULL)

#initialization (vehicle, facility, NULL, NULL, config)

output = calculateSolutionLeg(zone,vehicle, facility, config,1)


dfOutput = data.frame("echelon" = 1,
                      "zone_name" = c(zone[1]),
                      "zone_avg_size" = c(zone[2]),
                      "zone_area_km2" = c(zone[3]),
                      "zone_total_services" = c(zone[6]),
                      "zone_latitude" = c(zone[4]),
                      "zone_longitude" = c(zone[5]),
                      "facility_name" = c(facility[1]),
                      "facility_handling_time" = c(facility[2]),
                      "facility_latitude" = c(facility[3]),
                      "facility_longitude" = c(facility[4]),
                      "vehicle_name" = c(vehicle[1]),
                      "vehicle_capacity" = c(vehicle[2]),
                      "vehicle_velocicty_km.s" = c(vehicle[3]),
                      "vehicle_velocicty_stop_time" = c(vehicle[4]),
                      "total_distance_km" = c(output[1]),
                      "total_time_hours" = c(output[2]),
                      "number_vehicles" = c(output[3]))


write_outputJSON(path_in, dfOutput, two_echelon_output_filename)
