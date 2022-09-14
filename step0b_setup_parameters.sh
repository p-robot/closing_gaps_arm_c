# Script to set-up the parameters for running arm C communities
# as having the PopART intervention (i.e. CHiPs) with average 
# CHiPs coverage as the coverage of the intervention communities
# in the same triplet.  
# 
# W. Probert, 2022

source os_config.sh
source config.sh

Rscript R/average_chips_coverage.R 

# Copy parameters to the respective communities
for triplet in 1 2 3 4 5 6 7
do
    idx=$(( $triplet - 1 ))
    c=${communities[$idx]}
    cp parameters/average_chips_coverage_triplet_${triplet}/*.csv parameters/PARAMS_COMMUNITY${c}_ACCEPTED/

    # Adjust the patchinfo file
    Rscript R/adjust_patchinfo.R "parameters/PARAMS_COMMUNITY${c}_ACCEPTED/param_processed_patchinfo.txt"

done

