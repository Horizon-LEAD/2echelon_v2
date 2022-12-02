source(file.path(script_dirname, "calc.R"))
source(file.path(script_dirname, "io.R"))
source(file.path(script_dirname, "shape_to_zone.R"))

echelon <- function(file_config, file_services, file_facilities,
                    file_vehicles, file_zones, out_dir) {

    config <- read_config(file_config)
    facility <- read_facility(file_facilities, 1, config[3])
    vehicle <- read_vehicle(file_vehicles, 1, config[5])

    zone <- read_delivery_zone(file_zones, file_services, 1, FALSE, NULL)

    #initialization (vehicle, facility, NULL, NULL, config)

    output <- calc_solution_leg(zone, vehicle, facility, config, 1)

    dfoutput <- data.frame("echelon" = 1,
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


    write_json_out(dfoutput, paste(out_dir, "output.json", sep = "/"))
}