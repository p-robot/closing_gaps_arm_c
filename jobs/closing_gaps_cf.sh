#!/bin/bash
#$ -cwd -V
#$ -o log
#$ -e log
#$ -P fraser.prjc
#$ -q short.qc,jeeves.q,gromit.q,brienne.q
#$ -t 1-1000

module unload R
module load R/3.4.0-openblas-0.2.18-omp-gcc5.4.0

# Add path to GSL library
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gpfs0/apps/well/gsl/2.2.1-gcc4.9.3/lib/
export LD_LIBRARY_PATH

# Parse command line arguments
community=$1
input_dir=$2
output_dir=$3


# Strip tabs, white space, newline, carriage returns
community="${community//[$'\t\r\n ']}"

nruns=1000

declare -a arms=("B" "A" "C" "C" "A" "B" "C" "A" "B" "A" "B" "C" "B" "A" "C" "A" "C" "B" "A" "B" "C")
arm=${arms[$community-1]}
echo "Running for community $community, arm $arm"

ibm_dir="src" # PopART in patch 0 then rollout of CHiPs after the end of the trial (and CF)
ibm_dir_norollout="src_norollout" # PopART in patch 0 only, no rollout after the trial ends
ibm_dir_rollout="src_rollout" # No simulation of the PopART trial, CHiPs rollout after 2020

######################################################################
## Counterfactual                                                   #
## Do not run PopART, do not run any roll out                       #
#####################################################################
echo "------------------"
echo "Running counterfactual scenario"
echo "------------------"

CF=1

# Print time stamp of when IBM is started
printf '%-17.17s%-20.20s\n' 'DATE_START' "$(date +"%d/%m/%y %T")"

# Run the IBM
echo "********RUNNING IBM**********"
$ibm_dir/popart-simul.exe "$input_dir" $nruns $CF $SGE_TASK_ID 1 "$output_dir"

# Save end time stamp
printf '%-17.17s%-20.20s\n' 'DATE_END' "$(date +"%d/%m/%y %T")"

