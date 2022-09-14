# Python script to change macros in the model
#
# 

import sys
from os.path import join

input_file = sys.argv[1]
macro_name = sys.argv[2]
macro_value = sys.argv[3]
output_file = sys.argv[4]

if __name__ == "__main__":
    f = open(input_file, 'r')
    data = f.readlines()
    f.close()
    
    # Split on white space
    d = [[i, line] for i, line in enumerate(data) if line.startswith('#define ' + macro_name)]
    print("Found", macro_name, "at line", d[0][0])
    line = d[0][1]
    line = line.split()
    new_line = " ".join([line[0], line[1], macro_value, "\n"])
    
    # Add the line into the output data ... 
    for i, line in enumerate(data):
        if i == d[0][0]:
            data[i] = new_line
            print(data[i])

    
    # Write to file ... 
    
    f = open(output_file, 'w')
    f.writelines(data)
f.close()