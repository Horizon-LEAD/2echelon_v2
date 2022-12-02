# 2echelon_v2

_Updated version of the 2echelon model available in https://github.com/Horizon-LEAD/2echelon. Improved version that calculates 1echelon distribution networks and 2 echelon distribution networks._

## Instructions

```
docker run --rm \
	-v $PWD/sample-data:/data \
	registry.gitlab.com/inlecom/lead/models/echelon:v2.0.0 \
	/data/inputs/config.csv \
	/data/inputs/services.csv \
	/data/inputs/facilities.csv \
	/data/inputs/vehicles.csv \
	/data/inputs/zones.csv \
	/data/outputs
```

```
docker run --rm -it \
	-v $PWD/sample-data:/data \
	-v $PWD/src:/src \
	--entrypoint /bin/bash \
	echelon:v2.0.0
```

## Execution of Echelon Model from windows command line

1. Navigate to the \bin subdirectory on your R version directory (C:\Program Files\R\your_R_version_directory \bin)
2. Search & Replace del string C:\LEAD_MODELS\NEW\2echelon-main with the name of your directory and run the line below after updating the corresponding directory.
3. Define the input files and parameters according to the description of scenarios.json below.
4. Execution COMMANDS:
	1. `Rscript C:/LEAD_MODELS/NEW/2echelon-main/00_One_Echelon.R C:/LEAD_MODELS/NEW/2echelon-main/`
	2. `Rscript C:/LEAD_MODELS/NEW/2echelon-main/00_Two_Echelon.R  C:/LEAD_MODELS/NEW/2echelon-main/`
	3. `Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_One_Echelon_vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45`
	4. `Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_Two_Echelon_Leg1vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45`
	5. `Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_Two_Echelon_Leg2vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45`
	6. `Rscript C:/LEAD_MODELS/NEW/2echelon-main/02_Two_Echelon_UCC.R  C:/LEAD_MODELS/NEW/2echelon-main/ 40.4161737 -3.7087409`

### Inputs
1.	Rscript C:/LEAD_MODELS/NEW/2echelon-main/00_One_Echelon.R C:/LEAD_MODELS/NEW/2echelon-main/
2.	Rscript C:/LEAD_MODELS/NEW/2echelon-main/00_Two_Echelon.R  C:/LEAD_MODELS/NEW/2echelon-main/
		args[1] = the location of the folder that contains the scripts, the INPUT, OUTPUT, SHAPEFILES folder to run the scenario
3.	Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_One_Echelon_vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45
4.	Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_Two_Echelon_Leg1vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45
5.	Rscript C:/LEAD_MODELS/NEW/2echelon-main/01_Two_Echelon_Leg2vehicle.R  C:/LEAD_MODELS/NEW/2echelon-main/ "NV200,Electric,Cargo,Vehicle" 161 45
		args[1] = the location of the folder that contains the scripts, the INPUT, OUTPUT, SHAPEFILES folder to run the scenario
		args[2] = the name of the vehicle
		args[3] = the capacity of the vehicle (same metric that the average service)
		args[4] = the speed of the vehicle (km/s)
6.	Rscript C:/LEAD_MODELS/NEW/2echelon-main/02_Two_Echelon_UCC.R  C:/LEAD_MODELS/NEW/2echelon-main/ 40.4161737 -3.7087409
		args[1] = the location of the folder that contains the scripts, the INPUT, OUTPUT, SHAPEFILES folder to run the scenario
		args[2] = latitude
		args[3] = longitude

## Tested Platform
```
platform       x86_64-w64-mingw32
arch           x86_64
os             mingw32
system         x86_64, mingw32
status
major          4
minor          0.5
year           2021
month          03
day            31
svn rev        80133
language       R
version.string R version 4.0.5 (2021-03-31)
nickname       Shake and Throw
```

## Files Description
- Shapefile_to_Zone.r
	- functions for reading geographic data.
- TwoEchelonModel_script.r
	- functions for calculating the number of vehicles, distance and times for delivering for one echelon or two echelon configurations.
- TwoEchelonModel_IO.r
	- functions for reading the input parameters in the folder INPUT and writing the results in the folder OUTPUT folder. It contains complementary functions for converting the output data in the json files used by zlc_LEAD_to_from_COPERT.ipynb and zlc_LEAD_to_from_EVCO2.ipynb to connect to the corresponding models available in the LEAD library (COPERT) and EVCO2
- 00_One_Echelon.R
	- Script with the example code to run the one echelon model using default data saved in the csv files in the INPUT folder
- 00_Two_Echelon.R
	- Script with the example code to run the two-echelon model using default data saved in the csv files in the INPUT folder
- 01_One_Echelon_vehicle.R
	- Script with the example code to run the one echelon model using default data saved in the csv files in the INPUT folder but using
	another vehicle. The parameters are the name of vehicle , the capacity, the speed (km/h).
- 01_Two_Echelon_Leg1vehicle.R
	- Script with the example code to run the two-echelon model using default data saved in the csv files in the INPUT folder but using
	another vehicle for the first leg. The parameters are the name of vehicle , the capacity, the speed (km/h).
- 02_Two_Echelon_UCC.R
	- Script with the example code to run the two-echelon model using default data saved in the csv files in the INPUT folder  but using
	another location for the UCC. The parameters are latitude and longitude.

## Demo Inputs and Outputs

### Inputs

This folder contains the csv with the information provided by the LSP differentiated by scenario.

-facilites.csv
	- It contains the information of the facility supplying the delivery zone(1 facility if 1 echelon) or facilities supplying (2 if 2 echelon, the first supplies to the second facility and the second to the delivery zone.
- vehicles.csv
	- It contains the information of the vehicle supplying the first facility(1 vehicle if 1 echelon) or vehicles supplying (2 if 2 echelon, the first supplies to the second facility and the second to the delivery zone).
- config.csv
	- It contains parameters required for running the model as the workshift.
- zones.csv
	- it contains the information of the delivery zone (path to the source of data or the area and coordinates of a centric point).It contains the
	two fields for specifying the average number of deliveries and the average size of the parcel.
- services.csv
	- Optional. If available the column 19 must be filled with the size of the goods of the corresponding service it it is a pickup point.
	Column 20 must be filled with the size of the goods of the corresponding service it it is a delivery point. If not available, the model will use the attributes avg_zone
	and total_services from zones.csv

### Outputs

This folder will contain the result of executing the model

- output_two_echelon.json
	- it contains the results of the model and complementary data. if one echelon it will contain one record, if two echelon it will contain two records.


```
# output_two_echelon.json
[
	{
		'echelon' number of the leg {1:2}
		'zone_name'=name of the zone of the leg echelon,
		'zone_avg_size'= average size of the item deliver of the zone of the leg echelon,
		'zone_area_km2'=square km of the delivery zone of the zone of the leg echelon,
		'zone_total_services'=number of services to be delivered in zone_name of the zone of the leg echelon,
		'zone_latitude'= coordinate x of some concentric point of zone_name of the zone of the leg echelon,
		'zone_longitude'=coordinate y of some concentric point of zone_name of the zone of the leg echelon,
		'facility_name' = name of the facility of the leg echelon,
		'facility_handling_time' = handling time facility of the leg echelon,
		'facility_latitude'= latitude of the facility of the leg echelon,
		'facility_longitude'= longitude of the facility of the leg echelon,
		'vehicle_name'= name of the vehicle of the leg echelon,
		'vehicle_capacity'= capacity of the vehicle of the leg echelon,
		'vehicle_velocity_km.s'= velocity of the vehicle of the leg echelon,
		'vehicle_velocity_stop_time'= stop time of the vehicle of the leg echelon (h),
		'total_distance_km' = total distance made by the vehicle of the leg echelon to fulfill the leg echelon (km),
		'total_time_hours' = total time made by the vehicle of the leg echelon to fulfill the leg echelon (h),
		'number_vehicles' = total distance made by the vehicle of the leg echelon to fulfill the leg echelon
		}
]
```

### Shapefile folder

Folder for unziping the shapefile data of the delivery area in the case of the example of Madrid or saved the shapefile if available.
If this informations is not available, the coordinates and the square kms of the delivery zone must be available in the zones.csv file.

## Pastebin

```
docker run --rm --entrypoint Rscript \
	-v $PWD/INPUT:/data/INPUT \
	-v $PWD/src:/src \
	registry.gitlab.com/inlecom/lead/models/echelon:latest \
	src/00_One_Echelon.R /data
```