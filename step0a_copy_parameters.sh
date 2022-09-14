
source os_config.sh
source config.sh

source_dir="/well/fraser/users/probert/19_07_18_calibration_ias2019_param_limits/"

for community in ${communities_copied[@]}
do
    cp "$source_dir/results/results_Com${community}/PARAMS_COMMUNITY${community}_ACCEPTED.tar.gz" ./parameters/
done

echo "Parameters copied from $source_dir" >> ./parameters/README.txt
echo "on date $(date)" >> ./parameters/README.txt


for community in ${communities_copied[@]}
do
    (cd parameters; tar xzf PARAMS_COMMUNITY${community}_ACCEPTED.tar.gz)
done

