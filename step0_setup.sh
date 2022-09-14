# Script to setup folders and IBM code for the running networks on different scenarios of the IBM
# July 2020, W. Probert

source os_config.sh
source config.sh

mkdir -p log results parameters

# Scenario 1 and CF
for patch in 0 1
do
    ibm_dir="src_patch${patch}"
    rm -rf $ibm_dir
    mkdir -p $ibm_dir
    git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git $ibm_dir
    
    # Save the latest commit
    ./utilities/save_commit.sh $ibm_dir $github_username latest_commit_${ibm_dir}.log

    # Remove all files from the src folder except the source code
    # (a little bit of a hack but avoids having nested repos)
    rm $ibm_dir/*.* $ibm_dir/.gitignore
    rm -rf $ibm_dir/python/ $ibm_dir/doc/ $ibm_dir/data/ $ibm_dir/.git/ $ibm_dir/tests/
    mv $ibm_dir/src/* $ibm_dir/
    rm -r $ibm_dir/src

    # Adjust macros in the code.  
    declare -a macros=(WRITE_EVERYTIMESTEP PRINT_EACH_RUN_OUTPUT PRINT_ALL_RUNS ROLL_OUT_CHIPS_INSIDE_PATCH)
    for macro in ${macros[@]}
    do
        python python/change_macro.py $ibm_dir/constants.h $macro 1 $ibm_dir/constants.h
    done

    declare -a macros_zero=(WRITE_CALIBRATION ALLOW_COUNTERFACTUAL_ROLLOUT)
    for macro in ${macros_zero[@]}
    do
        python python/change_macro.py $ibm_dir/constants.h $macro 0 $ibm_dir/constants.h
    done

    python python/change_macro.py $ibm_dir/constants.h T_ROLLOUT_CHIPS_EVERYWHERE 2100 $ibm_dir/constants.h

    # Compile the code
    cd $ibm_dir
    make clean; make all location=rescomp compiler=gcc
    cd ..
done


# Scenario 2
for patch in 0 1
do
    ibm_dir="src_norollout_patch${patch}"
    rm -rf $ibm_dir
    mkdir -p $ibm_dir
    git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git $ibm_dir

    # Save the latest commit
    ./utilities/save_commit.sh $ibm_dir $github_username latest_commit_${ibm_dir}.log

    
    # Remove all files from the src folder except the source code
    # (a little bit of a hack but avoids having nested repos)
    rm $ibm_dir/*.* $ibm_dir/.gitignore
    rm -rf $ibm_dir/python/ $ibm_dir/doc/ $ibm_dir/data/ $ibm_dir/.git/ $ibm_dir/tests/
    mv $ibm_dir/src/* $ibm_dir/
    rm -r $ibm_dir/src

    # Adjust macros in the code.  
    declare -a macros=(WRITE_EVERYTIMESTEP PRINT_EACH_RUN_OUTPUT PRINT_ALL_RUNS)
    for macro in ${macros[@]}
    do
        python python/change_macro.py $ibm_dir/constants.h $macro 1 $ibm_dir/constants.h
    done

    declare -a macros_zero=(WRITE_CALIBRATION ALLOW_COUNTERFACTUAL_ROLLOUT ROLL_OUT_CHIPS_INSIDE_PATCH)
    for macro in ${macros_zero[@]}
    do
        python python/change_macro.py $ibm_dir/constants.h $macro 0 $ibm_dir/constants.h
    done

    python python/change_macro.py $ibm_dir/constants.h T_ROLLOUT_CHIPS_EVERYWHERE 2100 $ibm_dir/constants.h
    python python/change_macro.py $ibm_dir/constants.h T_STOP_ROLLOUT_CHIPS_INSIDE_PATCH 2018 $ibm_dir/constants.h

    # Compile the code
    cd $ibm_dir
    make clean; make all location=rescomp compiler=gcc
    cd ..
done

# Scenario 3
for patch in 0 1
do
    ibm_dir="src_rollout_patch${patch}"
    rm -rf $ibm_dir
    mkdir -p $ibm_dir
    git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git $ibm_dir

    # Save the latest commit
    ./utilities/save_commit.sh $ibm_dir $github_username latest_commit_${ibm_dir}.log


    # Remove all files from the src folder except the source code
    # (a little bit of a hack but avoids having nested repos)
    rm $ibm_dir/*.* $ibm_dir/.gitignore
    rm -rf $ibm_dir/python/ $ibm_dir/doc/ $ibm_dir/data/ $ibm_dir/.git/ $ibm_dir/tests/
    mv $ibm_dir/src/* $ibm_dir/
    rm -r $ibm_dir/src

    # Adjust macros in the code.  
    declare -a macros=(WRITE_EVERYTIMESTEP PRINT_EACH_RUN_OUTPUT PRINT_ALL_RUNS ALLOW_COUNTERFACTUAL_ROLLOUT ROLL_OUT_CHIPS_INSIDE_PATCH)
    for macro in ${macros[@]}
    do
        python python/change_macro.py $ibm_dir/constants.h $macro 1 $ibm_dir/constants.h
    done

    declare -a macros_zero=(WRITE_CALIBRATION)
    for macro in ${macros_zero[@]}
    do
        python python/change_macro.py $ibm_dir/constants.h $macro 0 $ibm_dir/constants.h
    done

    python python/change_macro.py $ibm_dir/constants.h T_ROLLOUT_CHIPS_EVERYWHERE 2020 $ibm_dir/constants.h

    # Compile the code
    cd $ibm_dir
    make clean; make all location=rescomp compiler=gcc
    cd ..
done

