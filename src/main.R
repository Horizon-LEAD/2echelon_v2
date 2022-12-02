#' Echelon main
#'
#' Rscript <path-to-main>/main.R <path-to-config-csv>
#'                               <path-to-services-csv>
#'                               <path-to-facilities-csv>
#'                               <path-to-vehicles-csv>
#'                               <path-to-area-zip>
#'                               <path-for-output>
#'
library("argparse")

# CLI argument parsing
parser <- ArgumentParser(description = "Process some integers")
parser$add_argument("config", type = "character",
                    help = "Config file")
parser$add_argument("services", type = "character",
                    help = "Services file")
parser$add_argument("facilities", type = "character",
                    help = "Facilities file")
parser$add_argument("vehicles", type = "character",
                    help = "Vehicles file")
parser$add_argument("zones", type = "character",
                    help = "The zones as a csv file")
parser$add_argument("outdir", type = "character",
                    help = "Output directory")

cli_args <- commandArgs(trailingOnly = FALSE)
print(cli_args)
args <- parser$parse_args()

# find directory of the script and source deps
script_name <- sub("--file=", "", cli_args[grep("--file=", cli_args)])
script_dirname <- dirname(script_name)

source(file.path(script_dirname, "echelon.R"))

echelon(args$config,
        args$services,
        args$facilities,
        args$vehicles,
        args$zones,
        args$outdir)
