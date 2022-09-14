

# Specify the github username (cause it's a private repo we're cloning)
github_username="p-robot"
branch_name="master"
repo_name="IBM_simul"
output_file="latest_commit.log"
repo_host="p-robot"

declare -a communities_copied=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21)
declare -a communities=(3 4 7 12 15 17 21)  # Communities to run this analysis for
T=2050                                # Final year of the simulation

# Map for community number to arm of the trial
declare -a arms=("B" "A" "C" "C" "A" "B" "C" "A" "B" "A" "B" "C" "B" "A" "C" "A" "C" "B" "A" "B" "C")

