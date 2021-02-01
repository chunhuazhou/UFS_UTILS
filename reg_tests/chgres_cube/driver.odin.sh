#!/bin/bash

#-----------------------------------------------------------------------------
#
# Run the chgres_cube regression tests on JET.
#
# Set OUTDIR to your working directory.  Set the PROJECT_CODE and QUEUE
# as appropriate.  To see which projects you are authorized to use,
# type "account_params".
#
# Invoke the script with no arguments.  A series of daily-
# chained jobs will be submitted.  To check the queue, type:
# "squeue -u USERNAME".
#
# The run output will be stored in OUTDIR.  Log output from the suite
# will be in LOG_FILE.  Once the suite has completed, a summary is
# placed in SUM_FILE.
#
# A test fails when its output does not match the baseline files as
# determined by the "nccmp" utility.  The baseline files are stored in
# HOMEreg.
#
#-----------------------------------------------------------------------------

set -x

source ../../sorc/machine-setup.sh > /dev/null 2>&1
module use ../../modulefiles
module load build.$target
module list

export OUTDIR=/scratch/$LOGNAME/chgres_cube/reg_tests/tests_out
PROJECT_CODE="debug"
QUEUE="debug"
export machine="odin"
#export HDF5_DISABLE_VERSION_CHECK=2
#-----------------------------------------------------------------------------
# Should not have to change anything below here.  HOMEufs is the root
# directory of your UFS_UTILS clone.  HOMEreg contains the input data
# and baseline data for each test.
#-----------------------------------------------------------------------------

export HOMEufs=$PWD/../..

export HOMEreg=/scratch/larissa.reames/chgres_cube/reg_tests.public.v2

export NCCMP=/scratch/software/Odin/python/miniconda3/bin/nccmp

LOG_FILE=regression.log
SUM_FILE=summary.log
rm -f $LOG_FILE* $SUM_FILE

export OMP_STACKSIZE=1024M
ulimit -s unlimited
ulimit -a

export APRUN=srun

rm -fr $OUTDIR

#-----------------------------------------------------------------------------
# Initialize C96 using FV3 warm restart files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log01
export OMP_NUM_THREADS=1
TEST1=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J c96.fv3.restart \
      -o $LOG_FILE -e $LOG_FILE ./c96.fv3.restart.sh)

#-----------------------------------------------------------------------------
# Initialize C192 using FV3 tiled history files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log02
export OMP_NUM_THREADS=1
TEST2=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J c192.fv3.history \
      -o $LOG_FILE -e $LOG_FILE ./c192.fv3.history.sh)

#-----------------------------------------------------------------------------
# Initialize C96 using FV3 gaussian nemsio files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log03
export OMP_NUM_THREADS=1
TEST3=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J c96.fv3.nemsio \
      -o $LOG_FILE -e $LOG_FILE ./c96.fv3.nemsio.sh)

#-----------------------------------------------------------------------------
# Initialize C96 using spectral GFS sigio/sfcio files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log04
export OMP_NUM_THREADS=6   # should match cpus-per-task
TEST4=$(sbatch --parsable --exclusive --nodes=6 -n 12 --ntasks-per-node=3 --cpus-per-task=6 -t 0:15:00 \
      -A $PROJECT_CODE -q $QUEUE -J c96.gfs.sigio -o $LOG_FILE -e $LOG_FILE ./c96.gfs.sigio.sh)

#-----------------------------------------------------------------------------
# Initialize C96 using spectral GFS gaussian nemsio files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log05
export OMP_NUM_THREADS=1
TEST5=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J c96.gfs.nemsio \
      -o $LOG_FILE -e $LOG_FILE ./c96.gfs.nemsio.sh)

#-----------------------------------------------------------------------------
# Initialize regional C96 using FV3 gaussian nemsio files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log06
export OMP_NUM_THREADS=1
TEST6=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J c96.regional \
      -o $LOG_FILE -e $LOG_FILE ./c96.regional.sh)

#-----------------------------------------------------------------------------
# Initialize C96 using FV3 gaussian netcdf files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log07
export OMP_NUM_THREADS=1
TEST7=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J c96.fv3.netcdf \
      -o $LOG_FILE -e $LOG_FILE ./c96.fv3.netcdf.sh)

#-----------------------------------------------------------------------------
# Initialize C192 using GFS GRIB2 data.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log08
export OMP_NUM_THREADS=1
TEST8=$(sbatch --parsable --exclusive --nodes=2 -n 12 --ntasks-per-node=6 -t 0:05:00 -A $PROJECT_CODE -q $QUEUE -J c192.gfs.grib2 \
      -o $LOG_FILE -e $LOG_FILE ./c192.gfs.grib2.sh)

#-----------------------------------------------------------------------------
# Initialize CONUS 25-KM USING GFS GRIB2 files.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log09
export OMP_NUM_THREADS=1   # should match cpus-per-task
TEST9=$(sbatch --parsable --exclusive -n 12 --ntasks-per-node=6 --nodes=2 -t 0:05:00 -A $PROJECT_CODE -q $QUEUE -J 25km.conus.gfs.grib2.conus \
      -o $LOG_FILE -e $LOG_FILE ./25km.conus.gfs.grib2.sh)

#-----------------------------------------------------------------------------
# Initialize CONUS 3-KM USING HRRR GRIB2 file WITH GFS PHYSICS.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log10
export OMP_NUM_THREADS=1   # should match cpus-per-task
TEST10=$(sbatch --parsable --exclusive -n 12 --ntasks-per-node=6 --nodes=2 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J 3km.conus.hrrr.gfssdf.grib2.conus \
      -o $LOG_FILE -e $LOG_FILE ./3km.conus.hrrr.gfssdf.grib2.sh)

#-----------------------------------------------------------------------------
# Initialize CONUS 3-KM USING HRRR GRIB2 file WITH GSD PHYSICS AND SFC VARS FROM FILE.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log11
export OMP_NUM_THREADS=1   # should match cpus-per-task
TEST11=$(sbatch --parsable --exclusive -n 12 --ntasks-per-node=6 --nodes=3 -t 0:10:00 -A $PROJECT_CODE -q $QUEUE -J 3km.conus.hrrr.newsfc.grib2.conus \
      -o $LOG_FILE -e $LOG_FILE ./3km.conus.hrrr.newsfc.grib2.sh)

#-----------------------------------------------------------------------------
# Initialize CONUS 13-KM USING NAM GRIB2 file WITH GFS PHYSICS .
#-----------------------------------------------------------------------------

LOG_FILE=regression.log12
export OMP_NUM_THREADS=1   # should match cpus-per-task
TEST12=$(sbatch --parsable --exclusive -n 12 --ntasks-per-node=6 --nodes=2 -t 0:05:00 -A $PROJECT_CODE -q $QUEUE -J 13km.conus.nam.grib2.conus \
      -o $LOG_FILE -e $LOG_FILE ./13km.conus.nam.grib2.sh)

#-----------------------------------------------------------------------------
# Initialize CONUS 13-KM USING RAP GRIB2 file WITH GSD PHYSICS .
#-----------------------------------------------------------------------------

LOG_FILE=regression.log13
export OMP_NUM_THREADS=1   # should match cpus-per-task
TEST13=$(sbatch --parsable --exclusive -n 12 --ntasks-per-node=6 --nodes=2 -t 0:05:00 -A $PROJECT_CODE -q $QUEUE -J 13km.conus.rap.grib2.conus \
      -o $LOG_FILE -e $LOG_FILE ./13km.conus.rap.grib2.sh)

#-----------------------------------------------------------------------------
# Initialize CONUS 13-KM NA USING NCEI GFS GRIB2 file WITH GFS PHYSICS .
#-----------------------------------------------------------------------------

LOG_FILE=regression.log14
export OMP_NUM_THREADS=1   # should match cpus-per-task
TEST14=$(sbatch --parsable --exclusive -n 12 --ntasks-per-node=6 --nodes=2 -t 0:05:00 -A $PROJECT_CODE -q $QUEUE -J 13km.na.gfs.ncei.grib2.conus \
      -o $LOG_FILE -e $LOG_FILE ./13km.na.gfs.ncei.grib2.sh)

#-----------------------------------------------------------------------------
# Create summary log.
#-----------------------------------------------------------------------------

LOG_FILE=regression.log
sbatch --nodes=1 -n 1 -t 0:01:00 -A $PROJECT_CODE -J chgres_summary -o $LOG_FILE -e $LOG_FILE \
       --open-mode=append -q $QUEUE -d\
       afterok:$TEST1:$TEST2:$TEST3:$TEST4:$TEST5:$TEST6:$TEST7:$TEST8:$TEST9:$TEST10:$TEST11:$TEST12:$TEST13:$TEST14 << EOF
#!/bin/bash
grep -a '<<<' $LOG_FILE*  > $SUM_FILE
EOF

exit 0