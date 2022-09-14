# Script to setup folders and IBM code for the running closing gaps analysis
# on the post-unblinding parameters
# Feb 2020, W. Probert

# Specify the github username (cause it's a private repo we're cloning)
github_username=$1
branch_name="master"
repo_name="IBM_simul"
output_file="latest_commit.log"
repo_host="p-robot"

# Remove the code folder (in case it has already been created)
rm -rf src

# Clone the private github repository (will be prompted for password)
# this clones the rakai_vmmc branch of IBM_simul repo into the folder src
git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git src

# Pull the latest commit number and save to file
./utilities/save_commit.sh src $github_username $output_file

# Scenario 1 and CF

# Remove all files from the src folder except the source code
# (a little bit of a hack but avoids having nested repos)
rm src/*.* src/.gitignore
rm -rf src/python/ src/doc/ src/data/ src/.git/
mv src/src/* src/
rm -r src/src

# Adjust macros in the code.  
module load python/3.5.2-gcc5.4.0
python python/change_macro.py ./src/constants.h WRITE_CALIBRATION 0 ./src/constants.h
python python/change_macro.py ./src/constants.h PRINT_ALL_RUNS 1 ./src/constants.h
python python/change_macro.py ./src/constants.h PRINT_EACH_RUN_OUTPUT 1 ./src/constants.h
python python/change_macro.py ./src/constants.h WRITE_EVERYTIMESTEP 1 ./src/constants.h
python python/change_macro.py ./src/constants.h MAX_POP_SIZE 1600000 ./src/constants.h
python python/change_macro.py ./src/constants.h MAX_N_YEARS 200 ./src/constants.h
python python/change_macro.py ./src/constants.h T_ROLLOUT_CHIPS_EVERYWHERE 2101 ./src/constants.h
python python/change_macro.py ./src/constants.h ROLL_OUT_CHIPS_INSIDE_PATCH 1 ./src/constants.h
python python/change_macro.py ./src/constants.h ALLOW_COUNTERFACTUAL_ROLLOUT 0 ./src/constants.h

# Compile the code
cd src
module load intel
make clean; make all location=rescomp compiler=gcc
cd ..


# Scenario 2

# Remove the code folder (in case it has already been created)
rm -rf src_norollout

# Clone the private github repository (will be prompted for password)
# this clones the rakai_vmmc branch of IBM_simul repo into the folder src
git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git src_norollout

# Pull the latest commit number and save to file
./save_commit.sh src_norollout $github_username latest_commit_norollout.log

# Remove all files from the src folder except the source code
# (a little bit of a hack but avoids having nested repos)
rm src_norollout/*.* src_norollout/.gitignore
rm -rf src_norollout/python/ src_norollout/doc/ src_norollout/data/ src_norollout/.git/
mv src_norollout/src/* src_norollout/
rm -r src_norollout/src

# Adjust macros in the code.  
module load python/3.5.2-gcc5.4.0
python python/change_macro.py ./src_norollout/constants.h WRITE_CALIBRATION 0 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h PRINT_ALL_RUNS 1 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h PRINT_EACH_RUN_OUTPUT 1 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h WRITE_EVERYTIMESTEP 1 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h MAX_POP_SIZE 1600000 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h MAX_N_YEARS 200 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h T_ROLLOUT_CHIPS_EVERYWHERE 2101 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h ROLL_OUT_CHIPS_INSIDE_PATCH 0 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h T_STOP_ROLLOUT_CHIPS_INSIDE_PATCH 2018 ./src_norollout/constants.h
python python/change_macro.py ./src_norollout/constants.h ALLOW_COUNTERFACTUAL_ROLLOUT 0 ./src_norollout/constants.h

# Compile the code
cd src_norollout
module load intel
make clean; make all location=rescomp compiler=gcc
cd ..

# Scenario 3

# Remove the code folder (in case it has already been created)
rm -rf src_rollout

# Clone the private github repository (will be prompted for password)
# this clones the rakai_vmmc branch of IBM_simul repo into the folder src
git clone --branch $branch_name https://${github_username}@github.com/${repo_host}/${repo_name}.git src_rollout

# Pull the latest commit number and save to file
./save_commit.sh src_rollout $github_username latest_commit_rollout.log

# Remove all files from the src folder except the source code
# (a little bit of a hack but avoids having nested repos)
rm src_rollout/*.* src_rollout/.gitignore
rm -rf src_rollout/python/ src_rollout/doc/ src_rollout/data/ src_rollout/.git/
mv src_rollout/src/* src_rollout/
rm -r src_rollout/src

# Adjust macros in the code.  
module load python/3.5.2-gcc5.4.0
python python/change_macro.py ./src_rollout/constants.h WRITE_CALIBRATION 0 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h PRINT_ALL_RUNS 1 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h PRINT_EACH_RUN_OUTPUT 1 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h WRITE_EVERYTIMESTEP 1 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h MAX_POP_SIZE 1600000 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h MAX_N_YEARS 200 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h ALLOW_COUNTERFACTUAL_ROLLOUT 1 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h ROLL_OUT_CHIPS_INSIDE_PATCH 1 ./src_rollout/constants.h
python python/change_macro.py ./src_rollout/constants.h T_ROLLOUT_CHIPS_EVERYWHERE 2020 ./src_rollout/constants.h

# Compile the code
cd src_rollout
module load intel
make clean; make all location=rescomp compiler=gcc
cd ..

