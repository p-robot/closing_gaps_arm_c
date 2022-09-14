#!/usr/bin/env bash
# 
# Call script for running simulations so as to output the complete transmission network for the inside
# and outside patch of the IBM.  This script will run this for the list of communities in the array below.  
# 
# W. Probert, 2019

source os_config.sh
source config.sh

# Script to submit jobs for all communities (or those in the list below).  
job_array=()

# Make log file
log_file="communities_scenarios_run_on_`date -I`.log"
echo "$(date)" >> ./$log_file

for community in ${communities[@]}
do
    # Location of input parameters and output files
    input_dir="parameters/PARAMS_COMMUNITY${community}_ACCEPTED"
    
    # Change the parameter simulations so that they run until T
    for p in 0 1
    do
        for param in "end_time_simul"
        do
            Rscript R/change_parameter.R $input_dir/param_processed_patch${p}_times.csv $param $T
        done
    done
    
    # Translate community number to arm
    arm=${arms[$community-1]}
    
    # If this is an arm A or B community, run all scenarios.  
    # if this is an arm C community only run counterfactual scenario.  
    if [ "$arm" != "C" ];
    then
        declare -a scenarios=("1" "2" "3" "CF")
    else
        declare -a scenarios=("CF")
    fi
    
    # Loop through all scenarios for the current community
    for scenario in ${scenarios[@]}
    do
        # Code and counterfactual options
        if [ "$scenario" == "1" ];
        then
            CF=0
            ibm_dir_prefix="src"

        elif [ "$scenario" == "2" ];
        then
            CF=0
            ibm_dir_prefix="src_norollout" # Scenario 2
             
        elif [ "$scenario" == "3" ];
        then
            CF=1
            ibm_dir_prefix="src_rollout" # Scenario 3
        elif [ "$scenario" == "CF" ];
        then
            CF=1
            ibm_dir_prefix="src" # Scenario 1 and CF scenario
        else
            echo "Unknown scenario, exiting"
            exit 1;
        fi
    
        for patch in 0 1
        do
        
            ibm_dir="${ibm_dir_prefix}_patch${patch}"
            scenario_dir="scenario_${scenario}_patch${patch}"
            output_dir="results/results_Com${community}/${scenario_dir}/Output"
        
            # Create the output directory folder (if it doesn't already exist)
            mkdir -p "$output_dir"
        
            job_name="networks_${community}_scenario_${scenario}_patch${patch}"
            
            job_id=`qsub -terse -N $job_name ./jobs/scenario_networks_job.sh $community "$input_dir" "$output_dir" "$ibm_dir" $CF`

            # Record log of what was submitted
            echo "" >> $log_file
            echo "community: $community, arm: $arm, scenario: $scenario, ibm_dir: $ibm_dir, CF: $CF" >> $log_file
            echo "input_dir: $input_dir, output_dir: $output_dir" >> $log_file
            echo "job name: $job_name, jid: $job_id" >> $log_file
            echo "" >> $log_file
        done
    done
done

