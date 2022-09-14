# Configuration file for OS-specific loads
# mainly for running scripts on Rescomp (linux-gnu)

if [[ "$OSTYPE" == "linux-gnu" ]];
then
    module load intel/2019a
    module unload zlib binutils GCCcore GCC
    module load GCC/8.3.0
    module unload GSL
    module load GSL/2.6-GCC-8.3.0
    module unload R
    module load R/3.4.0-openblas-0.2.18-omp-gcc5.4.0
    module unload python
    module load python/3.5.2-gcc5.4.0
fi

