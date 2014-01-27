export TAU_MAKEFILE=/home/andrea/myLib_andSDK/tau-2.22.2/openmp_mpi/x86_64/lib/Makefile.tau-mpi-pdt-openmp
export TAU_CALLPATH=1
export TAU_CALLPATH_DEPTH=2
export TAU_OPTIONS='-optCompInst -optRevert -optVerbose' 
export OMP_NUM_THREADS=8
tau_cc.sh  $1
tau_exec ./a.out
