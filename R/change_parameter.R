# Rscript to adjust specific parameter value of parameter files
# 
# This script opens the parameter file (input_file; i.e. param_processed_patch0_init.csv)
# changes the column with the header that matches `param_name` to the value `param_value`
# and re-saves this file in place.  This assumes the input file is space-delimited.  
# 
# Usage: 
# change_parameter.R <input_file> <param_name> <param_value>

args <- commandArgs(trailingOnly = TRUE)

input_file <- args[1]
param_name <- args[2]
param_value <- args[3]

df <- read.table(input_file, header = TRUE, sep = "", strip.white = TRUE)

if(param_name %in% colnames(df)){
    cat("Changing parameter", param_name, "\n");
}else{
    cat("Parameter", param_name, "not found; Exiting\n")
    quit()
}

# Change all rows for this column to the value of interest
df[,param_name] <- as.numeric(param_value)

write.table(df, file = input_file, sep = " ", row.names = FALSE, quote = FALSE)
