#---------------------------------------------------------
# I/O functions to read and write the inputs of the 2Echelon model and connect with the CO2 models
#------------------------------------------------------------
library(stringr)
library(jsonlite)

read_config <- function(path){
  #-----------------------------------------------------------
  #read default parameters from config
  #----------------------------------------------------------
  
  
  file_config=paste(path,"/INPUT/config.csv",sep="")
  fdconfig=read.csv(file_config,header=T,";")
  
  configUI = as.matrix(fdconfig,nrow=2,ncol=8,byrow=TRUE)
  configUI
  
  k= configUI[1,1]
  workshift = configUI[1,2]
  handlingTimeFirstEchelon = configUI[1,3]
  handlingTimeSecondEchelon = configUI[1,4]
  stopTimeFirstEchelon = configUI[1,5]
  stopTimeSecondEchelon = configUI[1,6]
  distanceType = configUI[1,7]
  haversineCalibration= configUI[1,8]
  config =c(k,workshift, handlingTimeFirstEchelon,	handlingTimeSecondEchelon,	stopTimeFirstEchelon,	stopTimeSecondEchelon,	distanceType,	haversineCalibration)
  
  return(config)
  
}

read_facility <- function(path, i, handlingTime){
  #---------------------------------------------------------------
  #Read data of facilities to serve the consumers. First row of the file_facilities (.csv) with the information of the facilities
  #i = leg
  #---------------------------------------------------------------
  
  
  file_facilities=paste(path,"/INPUT/facilities.csv",sep="")
  fdFacilities=read.csv(file_facilities,header=F,";")
  
  
  #FacilityUI = Information in the file (Name	Address	Number	City	ZipCode	Latitude	Longitude	HandlingTime (minutes) StartHour	EndHour)
  facilityUI = as.matrix(fdFacilities,nrow=3,ncol=10,byrow=TRUE)
  
  #Model data input : facility = (name, handling time(h), latitude, longitude)'
  #facility first leg in San Fernando = origin of the route
  facility = c(facilityUI[i,1], handlingTime, as.double(facilityUI[i,6]),as.double(facilityUI[i,7]))
  
  return (facility)
}

read_vehicle <- function(path, i, stopTime){
  #--------------------------------------------------------------------
  #Read data of the vehicles to serve the consumer.  First row of the #document (.csv) contains the information for the 
  #first leg and the the second row for the second leg.
  #i = leg
  #--------------------------------------------------------------------
  
  file_vehicles=paste(path,"/INPUT/vehicles.csv",sep="")
  fdVehicles=read.csv(file_vehicles,header=F,";")
  vehiclesUI = as.matrix(fdVehicles,nrow=3,ncol=7,byrow=TRUE)
  
  #vehicle =  (name, capacity (Porto in boxes), speed (km/h), stop time (h))
  vehicle = c(vehiclesUI[i,1], vehiclesUI[i,2], vehiclesUI[i,6], stopTime)
  
  return (vehicle)
  
}

get_vehicle_attributes<- function(vehicle){
  #--------------------------------------------------------------------------------------------
  #convert the string with the attributes of the vehicles to a vector with the attributes
  #----------------------------------------------------------------------------------------------
  
  temp = strsplit(vehicle, split = ",")
  vehicle_attributes = c(unlist(temp), ncol=4, byrow=TRUE)
  
  return(vehicle_attributes)
}

read_services <- function(path){
  #read the file services and return the number of delveries and the average size if the file exists
  
  zone_services_fields=c(0,0)


  file_services=paste(path,"/INPUT/services.csv",sep="")
  fd= read.csv(file_services,header=F,"\t")
  zoneAvgOrderSize=(mean(na.omit(fd$V20))+ mean(na.omit(fd$V19)))/2
  zoneNOrders=nrow(fd)
  zoneAggregatedOrdersSize = sum(na.omit(fd$V20)) + sum(na.omit(fd$V19))
  zone_services_fields = c(zoneAvgOrderSize, zoneNOrders)
  
  print( zone_services_fields[1])
  
  return  (zone_services_fields)
}


read_services_ErroHandling <- function(code){
  #most cases the file with the services will not exist. this code is for handling with the exception.
  print("error handling")
 
  zone_services_fields=c(0,0)
  
  zone_services_fields = tryCatch(code, 
           error = function(c) {
             message("error")
             zone_services_fields=c(0,0)
             },
           warning = function(c) {
             message("warning")
             zone_services_fields=c(0,0)
             },
           message = function(c) {
             message("message")
             zone_services_fields=c(0,0)
           }
  )
  
  return(zone_services_fields)
}
  
  


read_deliveryZone <- function(path,i,is_twoEchelon, facility){
  #--------------------------------------------------------------------
  #read the data of the delivery zone
  #--------------------------------------------------------------------
  
  #read zones
  file_zones=paste(path,"/INPUT/zones.csv",sep="")
  fdZones=read.csv(file_zones,header=T,";")
  zonesUI = as.matrix(fdZones,nrow=2,ncol=9,byrow=TRUE)
  
  #number of services and average size will be read from different sources depending on if the services.csv is available
  fdServices = read_services_ErroHandling(read_services(path))
  if(fdServices[1]==0) {
    zoneAvgOrderSize=zonesUI[1,10]
    zoneNOrders=zonesUI[1,11]
    
    
  }else{
    zoneAvgOrderSize=fdServices[1]
    zoneNOrders=fdServices[2]
    
  }
  
  if(is_twoEchelon && i==1){
    totalSize=as.double(zoneAvgOrderSize)*strtoi(zoneNOrders)
    zone = c(1,totalSize,0, facility[3], facility[4],1)
  }else{
    
    zoneAux= c(zonesUI[1,3], zonesUI[1,4], zonesUI[1,5], zonesUI[1,6])
    print(strtoi(zoneAux[1]))
    
    if (strtoi(zoneAux[1])== 1 || strtoi(zoneAux[3]==1)){
      
      
      if(strtoi(zoneAux[1])== 1) { #the case of Madrid
        str_url = zoneAux[2]
        str_file_name=paste(path,zoneAux[4],sep="")
        Read_url_GeographicData(str_url,path)
        
      }
      else{
        if (strtoi(zoneAux[3])== 1){
         
          str_file_name=paste(path,zoneAux[4],sep="")
          
        }
      }
      zoneArea = Read_area(str_file_name)
      
      zoneArea = zoneArea/1000000
      zoneCentroid = Read_centroid(str_file_name)
      zoneCentroidGeometry = st_geometry(zoneCentroid)
      zoneCoordinatesCentroid = st_coordinates(zoneCentroidGeometry)
      zoneCentroidX = zoneCoordinatesCentroid[2]
      zoneCentroidY = zoneCoordinatesCentroid[1]
    }else{
      zoneArea = zonesUI[1,7]
      zoneCentroidX = zonesUI[1,8]
      zoneCentroidY = zonesUI[1,9]
      
    }
    
   
    
    zone = c(i,zoneAvgOrderSize,zoneArea, zoneCentroidX, zoneCentroidY,zoneNOrders)
  }
  
  
  return(zone)
  
}

write_outputJSON<- function(path,dfOutput, filename){
  #--------------------------------------------------------------------
  #write the output in the output file (.json); only the outputs
  #--------------------------------------------------------------
  
  
  dfOutput_json = toJSON(dfOutput, pretty=TRUE)
  
  
  
  file_output=paste(path,"/OUTPUT/", sep="")
  file_output=paste(file_output,filename, sep="")
  fd=write(dfOutput_json, file_output)
  
  return(fd)
  
  
}

twoEchelon_output_to_CO2_Models_outputJSON <- function (path, str_file_in, str_file_out, echelon_index){
  #--------------------------------------------------------------------
  #This function reads the output produced by the 2Echelon model and creates the file input for the wrapper
  #function developed for the LMT optimization model
  #--------------------------------------------------------------------
  
  file_input=paste(path,"/OUTPUT/", sep="")
  str_file_in=paste(file_input,str_file_in, sep="")
  # Passing argument files
  input =fromJSON(str_file_in)
  # Convert JSON file to dataframe.
  df = as.data.frame(input)
  #browser()
  
  #extract number of rows
  n=nrow(df)
  #access to the first vehicle (if one echelon just one row; if two echelon the first row)
  vehicle = df[echelon_index,12] #it contains the category, fuel, segment and Eurostandard columns separated by semicolon
  vehicle_attributes = get_vehicle_attributes(vehicle)
  distance =df[echelon_index,16]
  m=df[echelon_index,18]
  distance = distance/m #the average distance
  
  
  dfOutput = data.frame('ResponsePlanId'=0,
                        'Category'=vehicle_attributes[1],
                        'Fuel'=vehicle_attributes[2],
                        'Segment'=vehicle_attributes[3],
                        'EuroStandard'=vehicle_attributes[4],
                        'Stock'= m,
                        'MeanActivity'=distance)
  
  dfOutput_json = toJSON(dfOutput, pretty=TRUE)
  
  fd=write(dfOutput_json, str_file_out)
  
  return(fd)
  
}

twoEchelon_output_to_COPERT_outputJSON <- function (path, str_file_in, str_file_out, echelon_index){
#--------------------------------------------------------------------
#This function reads the output produced by the 2Echelon model and creates the file input for the wrapper
#function developed for the LMT optimization model
#--------------------------------------------------------------------
 
  file_input=paste(path,"/OUTPUT/", sep="")
  str_file_in=paste(file_input,str_file_in, sep="")
 
 #browser()
  # Passing argument files
  input =fromJSON(str_file_in)
  # Convert JSON file to dataframe.
  df = as.data.frame(input)
  
  #extract number of rows
  n=nrow(df)
  #browser()
  #access to the first vehicle (if one echelon just one row; if two echelon the first row)
  vehicle = df[echelon_index,12] #it contains the category, fuel, segment and Eurostandard columns separated by semicolon
  vehicle_attributes = get_vehicle_attributes(vehicle)
  distance =df[echelon_index,16]
  m=df[echelon_index,18]
  distance = distance/m #the average distance
  
  
  dfOutput = data.frame('ResponsePlanId'=0,
                        'Category'=vehicle_attributes[1],
                        'Fuel'=vehicle_attributes[2],
                        'Segment'=vehicle_attributes[3],
                        'EuroStandard'=vehicle_attributes[4],
                        'Stock'= m,
                        'MeanActivity'=distance)
  
  dfOutput_json = toJSON(dfOutput, pretty=TRUE)
  
  fd=write(dfOutput_json, str_file_out)
  
  return(fd)
  
}

twoEchelon_output_to_EVCO2_outputJSON <- function (path, str_file_in, str_file_out,echelon_index){
  #--------------------------------------------------------------------
  #This function reads the output produced by the 2Echelon model and creates the file input for the wrapper
  #function developed for the LMT optimization model
  #--------------------------------------------------------------------
  
  file_input=paste(path,"/OUTPUT/", sep="")
  str_file_in=paste(file_input,str_file_in, sep="")
  
  
  # Passing argument files
  input =fromJSON(str_file_in)
  # Convert JSON file to dataframe.
  df = as.data.frame(input)

 
  #extract number of rows
  n=nrow(df)
  #browser()
  
  echelon_index=2
  #access to the first vehicle (if one echelon just one row; if two echelon the first row)
  vehicle = df[echelon_index,12] #it contains the category, fuel, segment and Eurostandard columns separated by semicolon
  vehicle_attributes = get_vehicle_attributes(vehicle)
  distance =df[echelon_index,16]
  m=df[echelon_index,18]
  velocity = df[echelon_index,14]
  distance = distance/m #the average distance
  
  
  dfOutput = data.frame('ResponsePlanId'=0,
                        'Category'=vehicle_attributes[1],
                        'Fuel'=vehicle_attributes[2],
                        'Segment'=vehicle_attributes[3],
                        'EuroStandard'=vehicle_attributes[4],
                        'Stock'= m,
                        'MeanActivity'=distance,
                        'Velocity'=velocity)
  
  dfOutput_json = toJSON(dfOutput, pretty=TRUE)
  
  fd=write(dfOutput_json, str_file_out)
  
  return(fd)
  
}
# ----------------------------------------------------------------------------------------------------------------------

create_dir_day<- function (path,name_folder_out){
  #leg=1
  date=Sys.Date()
  today=format(date)
  name_dir = str_replace_all(today, "-", "")
  name_dir=paste(name_dir,name_folder_out,sep="")
  #path=getwd()
  
  setwd(path)
  dir.create(name_dir)
  name_dir = paste(path,name_dir,sep="/")
  
  return(name_dir)
  
}

#----------------------------------------------------------------------------------------------------------------



# create_dir_day<- function (path,leg){
#   #leg=1
#   date=Sys.Date()
#   today=format(date)
#   name_dir = str_replace_all(today, "-", "")
#   name_dir=paste(name_dir,"_LL",sep="")
#   name_dir = paste(name_dir,leg,sep="")
#   name_dir = paste(name_dir,"_zlc",sep="")
#   #path=getwd()
# 
#   setwd(path)
#   dir.create(name_dir)
#   name_dir = paste(path,name_dir,sep="/")
#   
#   return(name_dir)
#   
# }
# 

LL1_output_path <- function (path_out, file_name_out){
  
  date=Sys.Date()
  today=format(date)
  setwd(path_out)
  dir.create(today)
  path_out =paste(path_out,today, sep="/")
  file_name_out =paste(path_out,file_name_out, sep="/")
  
  return (file_name_out)
}

LL1_update_services<- function (path,file_in) {
  #replace the input file services in the system with the file file_in
  file_out=paste(path,"/INPUT/services.csv",sep="")
  file.copy(file_in, file_out, overwrite = TRUE,copy.mode = TRUE, copy.date = FALSE)
  
}


LL1_update_vehicles<- function (path,file_in) {
  #replace the input file vehicles in the system with the file file_in
  file_out=paste(path,"/INPUT/vehicles.csv",sep="")
  file.copy(file_in, file_out, overwrite = TRUE,copy.mode = TRUE, copy.date = FALSE)
  
}

LL1_update_facilities<- function (path,file_in) {
  #replace the input file facilities in the system with the file file_in
  file_out=paste(path,"/INPUT/facilities.csv",sep="")
  file.copy(file_in, file_out, overwrite = TRUE,copy.mode = TRUE, copy.date = FALSE)
  
}

LL1_update_zones<- function (path,file_in) {
  #replace the input file zones in the system with the file file_in
  file_out=paste(path,"/INPUT/zones.csv",sep="")
  file.copy(file_in, file_out, overwrite = TRUE,copy.mode = TRUE, copy.date = FALSE)
  
}


LL1_update_config<- function (path,file_in) {
  #replace the input file config in the system with the file file_in
  file_out=paste(path,"/INPUT/config.csv",sep="")
  file.copy(file_in, file_out, overwrite = TRUE,copy.mode = TRUE, copy.date = FALSE)
  
}

