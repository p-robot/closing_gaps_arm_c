#!/usr/bin/env bash
# 
# Submit jobs to Rescomp for generating extended output 
# from the IBM so as to calculate HIV/ART status in the 
# population.  This runs counterfactual simulations.  
# This job will run ~1000 simulations for each of the 
# 1000 accepted parameters from the calibration for 
# community 1 (Zambia, arm B).  Parameters were generated
# from calibration in 
# /well/fraser/users/probert/19_07_18_calibration_ias2019_param_limits.
# (The calibration before IAS 2019).  
# 
# See ./jobs/hptn_risk_groups_jobs.sh for details of the job script.  
# 
# W. Probert, 2019

declare -a communities=(8 9 10 11)

# Time at which the simulations should end
T=2031

scenario="scenario_3_lt35m"

# Loop over communities.  
for community in ${communities[@]}
do
    # Location of input parameters and output files
    source_dir="parameters/PARAMS_COMMUNITY${community}_ACCEPTED"
    output_dir="results/results_Com${community}/${scenario}/Output"
    
    # Copy the input directory for the scenario in question
    input_dir="${source_dir}_${scenario}"
    cp -r "$source_dir" "$input_dir"

    # Create the output directory folder (if it doesn't already exist)
    mkdir -p "$output_dir"

    # Change the parameter simulations so that they run until T
    for p in 0 1
    do
        for param in "end_time_simul"
        do
            Rscript R/change_parameter.R $input_dir/param_processed_patch${p}_times.csv $param $T
        done
    done

    # Adjust the CHiPs schedule for those in younger age groups of men.  
    # Loop through chips rounds and patches
    for chips_round in "posttrial"
    do
        for patch in 0 1
        do
            input_file="param_processed_patch${patch}_chipsuptake_round${chips_round}.csv"
            python python/scale_chips_coverage_by_age.py --uptake_file "$input_dir/$input_file" \
                --start_age 18 --end_age 34 --genders "M" --other_coverage "0.0"
        done
    done
    
    # Submit the job (as an array job) for the community in question
    qsub -N closing_gaps_CL${community}_${scenario} "./jobs/closing_gaps_scenario3.sh" $community $input_dir $output_dir

done

