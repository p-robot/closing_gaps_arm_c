# Script to count (and display file name of) non-empty 
# error files in the 'log' folder
# 
# Usage: ./utilities/check_error_files.sh <pattern>
# 
# pattern: pattern in name of error files (if you want to 
#          check only error files for a particular job)
# 
# W. Probert (p-robot), 2019

if [ $# -eq 1 ]
then
    pattern="*$1*"
else
    pattern="*"
fi

NFILES=$(find log -type f -name "$pattern" -and -name "*.e*"  | wc -l)
echo "$NFILES error files matching the pattern"
nonempty_counter=0

# This approach fails if there are too many error files
#for f in `ls log/*.e* | grep "$pattern"`

for f in `find log -type f -name "$pattern" -and -name "*.e*"`
do
    if [ -s $f ] 
    then
        echo $f
        ((nonempty_counter++))
    fi
done

# Print summary
echo $nonempty_counter " non-empty files of $NFILES log files"

