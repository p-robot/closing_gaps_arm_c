# Python script to scale CHiPs coverage in young age groups
#
# Usage: 
# python scale_chips_coverage_by_age.py coverage_file start_age1 end_age1 start_age2 end_age2
# 
# Arguments
#     uptake_file : the CHiPs coverage file
#     start_age : starting age of which to edit
#     end_age : ending age of which to edit
#     end_coverage : ending age from which we will copy the per-time-step coverage

from os.path import join
import numpy as np, sys, argparse

# First 3 columns are time(fractional) year (int) timestep(int)
# Then columns are males 18 - males 80 then females 18 - females 80
# There should be (80 - 18 + 1)*2 + 3 = 129 columns in total
COL_SKIP = 3
AGE_CHIPS = 18
AGE_MAX = 80
N_ALL_AGES = 80 - 18 + 1

if __name__ == "__main__":
    
    # Process the input argument
    parser = argparse.ArgumentParser()

    parser.add_argument("-f", "--uptake_file", type = str, help = "Uptake file")

    parser.add_argument('--start_age', help = "Starting age", 
        type = int, default = 0)

    parser.add_argument('--end_age', help = "Ending age", 
        type = int, default = 0)

    parser.add_argument('--end_coverage', help = "Final (end of round) coverage for age group (The default None will leave these ages unchanged)", 
        type = float, default = None)

    parser.add_argument('-g','--genders', help = "Genders to adjust", 
        nargs = '+', type = str, default = ["M", "F"])
    
    parser.add_argument('--other_coverage', \
        help = "Final (end of round) coverage for all other groups", \
        type = float, default = None)
    
    args = parser.parse_args()
    
    f = open(args.uptake_file, 'r')
    data = f.readlines()
    f.close()

    header = data[0].rstrip()

    NTIMESTEPS = len(data) - 1

    # Split the data up into values
    new_data = [l.split() for l in data[1:]]
    
    # Loop through genders
    for i_gender, gender in enumerate(args.genders):
        # Loop through ages
        for age in range(args.start_age, args.end_age + 1):
            # Find the column of interest
            i_col = COL_SKIP + (age - AGE_CHIPS) + i_gender*(AGE_MAX - AGE_CHIPS + 1)
            
            values = [float(new_data[i][i_col]) for i in range(NTIMESTEPS)]
            
            # Scale the old values if needed
            if args.end_coverage is None:
                new_values = [str(v) for v in values]
            else:
                
                total = np.sum(values)
                # Calculate the scaling factor
                if total == 0:
                    scaling_factor = 0.0
                else:
                    scaling_factor = args.end_coverage / float(total)
                
                new_values = [str(v*scaling_factor) for v in values]
            
            # Assign the new data in place
            for i in range(NTIMESTEPS):
                new_data[i][i_col] = new_values[i]
    
    # Check that args.other_coverage is a float (not None)
    if args.other_coverage is not None:
        # Adjust other coverage in all other groups
        # Find genders we've not changed
        other_genders = [g for g in ["M", "F"] if g not in args.genders]
        # Find ages we've not changed
        other_ages = [a for a in range(AGE_CHIPS, AGE_MAX+1) if a not in \
            range(args.start_age, args.end_age + 1)]
    
        # Loop through genders
        for i_gender, gender in enumerate(["M", "F"]):
            # Loop through ages
            for age in range(AGE_CHIPS, AGE_MAX+1):
                
                # Check this is an age/gender we need to adjust
                if not((gender in args.genders) & (age in range(args.start_age, args.end_age + 1))):
                    
                    # Find the column of interest
                    i_col = COL_SKIP + (age - AGE_CHIPS) + i_gender*(AGE_MAX - AGE_CHIPS + 1)
                
                    values = [float(new_data[i][i_col]) for i in range(NTIMESTEPS)]
                    total = np.sum(values)
            
                    # Calculate the scaling factor
                    if total == 0:
                        scaling_factor = 0
                    else: 
                        scaling_factor = args.other_coverage / float(total)
            
                    # Scale the old values
                    new_values = [str(v*scaling_factor) for v in values]
            
                    # Assign the new data in place
                    for i in range(NTIMESTEPS):
                        new_data[i][i_col] = new_values[i]
    
    output_lines = [header] + [" ".join(l) for l in new_data]
    output_lines = "\n".join(output_lines)
    
    output_file = args.uptake_file

    # Write to file ... 
    f = open(output_file, 'w')
    f.writelines(output_lines)
    f.close()
