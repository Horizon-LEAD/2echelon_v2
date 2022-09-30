
#Rscript C:/LEAD_MODELS/NEW/2echelon-main/LEAD_LL1_connector.R  "_as-is_zlc_electric_van"
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Description: 
#     Script for creating the inputs and the dependencies for  wrapping function that connects to the next models (COPERT, EVCO2, both)
#     args[1] = name of the folder will be created to save the intermediate results will be used by the jupyter notebooks. It must follow the name convention defined with Angel.
#     ---Possibilities:
#     ---[1] name_folder_out="_as-is_zlc_diesel_van"                        ---> AS IS (script 00_One_Echelon.R)
#     ---[2] name_folder_out="_as-is_zlc_electric_van"                      ---> AS IS using electric van (script 01_One_Echelon_vehicle.R with the parameters of the electric van)
#     ---[3] name_folder_out="_as-is_zlc_hybrid_van"                        ---> AS IS using hybrid van (script 01_One_Echelon_vehicle.R with the parameters of the hybrid van))
#     ---[4] name_folder_out="_as-is_zlc_electric_scooter"                  ---> AS IS using hybrid van (script 01_One_Echelon_vehicle.R with the parameters of the electric scooters))
#     ---[5] name_folder_out="_to-be_zlc_hybrid_van _electric_scooter"      ---> TO BE (script 00_Two_Echelon.R)
#     ---[6] name_folder_out="_to-be_zlc_electric_van _electric_scooter"    ---> TO BE using electric van in the first leg (script 01_Two_Echelon_Leg1vehicle.R with the parameters of the electric van)
#     ---[7] name_folder_out="_to-be_zlc_hybrid_van _electric_scooter_newUCC" --> TO BE changing the location of the UCC (02_Two_Echelon_UCC.R with the latitude and longitude of the new UCC)
#
#    
#     
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#reading the parameters from the console
args= commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
#stop("One arguments need to be supplied", call.=FALSE)
  name_folder_out="_as-is_zlc_diesel_van"
 
 } else if (length(args)==1) {
   print("hola")
#   # default output file
   name_folder_out = args[1]
}


#predefined parameters
path_in = "C:/LEAD_MODELS/NEW/2echelon-main/"                             #folder with the script "TwoEchelonModel_IO.R" for creating the directory 
path_in_output = "C:/LEAD_MODELS/NEW/2echelon-main/OUTPUT"                #folder with the result of the Echelon Model 
two_echelon_output_filename="output_two_echelon.json"                     #Output of twoEchelon model - name of the output file with the results and all the information of the scenario. 
input_COPERT_json="zlc_LEAD_input_to_COPERT.json"                         #name of the output file with structure required by the jupyter notebook if non electric vehicles
input_EVCO2_json="zlc_LEAD_input_to_EVCO2.json"                           #name of the output file with structure required by the jupyter notebook if  electric vehicles

path_CO2_models = "C:/LEAD_MODELS/NEW/2ECHELON_2_CO2_MODELS"              #folder that contains the templates used by the jupyter notebooks
input_COPERT_xlsx="zlc_LEAD_input_to_COPERT.xlsx"                         #name of the file will be used by the next model if non-electric (COPERT)
input_EVCO2_1_factors_xlsx="zlc_LEAD_input_to_EVCO2_1_factors.xlsx"                           #name of the file will be used by the next model if electric (EVCO2)
input_EVCO2_2_energy_consumption_xlsx="zlc_LEAD_input_to_EVCO2_2_energy_consumption.xlsx"     #name of the file will be used by the next model if electric (EVCO2)

path_out= "C:/Users/broyo/Dropbox/LL_1_as-is_diesel_van_runs"             #folder to save the intermediate calculations and results after executing the jupyter notebooks

setwd(path_in)
source("TwoEchelonModel_IO.R")


#read the output file of the twoEchelon to find the characteristics to create the inputs of the jupyter notebooks

str_file_out=""
str_file_out=paste(path_in_output, two_echelon_output_filename,sep="/")

output =fromJSON(str_file_out)
df_Output = as.data.frame(output)

numberLegs=nrow(df_Output) #number of legs
path_out_2 =create_dir_day(path_out,name_folder_out)

#first leg calculation if Diesel
vehicleName1 =df_Output[1,"vehicle_name"]
vehicle1_isElectric = str_detect(vehicleName1, "Electric")

if(vehicle1_isElectric){
  if(numberLegs==1){
    print("execution electric vehicle for one echelon, preparing EVCO2 files")
    #copy zlc_LEAD_input_to_EVCO2_1_factors.xlsx to the directory of the day
    input_EVCO2_1_xlsx=paste(path_CO2_models,input_EVCO2_1_factors_xlsx,sep="/")
    file.copy(from=input_EVCO2_1_xlsx, to=path_out_2, overwrite=T)
    #copy zlc_LEAD_input_to_EVCO2_2_energy_consumption.xlsx to the directory of the day
    input_EVCO2_2_xlsx=paste(path_CO2_models,input_EVCO2_2_energy_consumption_xlsx,sep="/")
    file.copy(from=input_EVCO2_2_xlsx, to=path_out_2, overwrite=T)
    
     #code for converting the one echelon output into the input for COPERT
      str_file_out=paste(path_out_2, input_EVCO2_json,sep="/")
      twoEchelon_output_to_CO2_Models_outputJSON(path_in, two_echelon_output_filename, str_file_out,1)
  }else{
    print("to be determined")
}
}else{
    print("vehicle for first leg is not electric, preparing COPERT files")
    #code for calculating the outputs for the one echelon configuration
    file_COPERT_xlsx=paste(path_CO2_models,input_COPERT_xlsx,sep="/")
    file.copy(from=file_COPERT_xlsx, to=path_out_2, overwrite=T) 
    # code for converting the one echelon output into the input for COPERT
    str_file_out=paste(path_out_2, input_COPERT_json,sep="/")
    twoEchelon_output_to_CO2_Models_outputJSON(path_in, two_echelon_output_filename, str_file_out,1)
    
    if(numberLegs==2){
      #browser()
        
      print("execution electric vehicle for 2 echelon second leg, preparing EVCO2 files")
      #copy zlc_LEAD_input_to_EVCO2_1_factors.xlsx to the directory of the day
      input_EVCO2_1_xlsx=paste(path_CO2_models,input_EVCO2_1_factors_xlsx,sep="/")
      file.copy(from=input_EVCO2_1_xlsx, to=path_out_2, overwrite=T)
      #copy zlc_LEAD_input_to_EVCO2_2_energy_consumption.xlsx to the directory of the day
      input_EVCO2_2_xlsx=paste(path_CO2_models,input_EVCO2_2_energy_consumption_xlsx,sep="/")
      file.copy(from=input_EVCO2_2_xlsx, to=path_out_2, overwrite=T)
      
      #code for converting the one echelon output into the input for COPERT
      str_file_out=paste(path_out_2, input_EVCO2_json,sep="/")
      twoEchelon_output_to_CO2_Models_outputJSON(path_in, two_echelon_output_filename, str_file_out,2)
    }
}




