#!/bin/bash

#-----------------------------------------------------------------------------
# Invoke chgres to create C96 coldstart files using spectral GFS nemsio data
# as input.  The coldstart files are then compared to baseline files
# using the 'nccmp' utility.  Run from the machine specific driver script.
#-----------------------------------------------------------------------------

set -x

export DATA=$OUTDIR/c96_gfs_nemsio
rm -fr $OUTDIR

export FIXfv3=${HOMEreg}/fix/C96
export COMIN=${HOMEreg}/input_data/gfs.nemsio
export ATM_FILES_INPUT=gfnanl.gdas.2017071700
export SFC_FILES_INPUT=sfnanl.gdas.2017071700
export NST_FILES_INPUT=nsnanl.gdas.2017071700
export VCOORD_FILE=${HOMEufs}/fix/fix_am/global_hyblev.l64.txt
export INPUT_TYPE="gfs_gaussian"
export TRACERS_OUTPUT='"sphum","liq_wat","o3mr"'
export TRACERS_INPUT='"spfh","clwmr","o3mr"'
export CDATE=2017071700
export OMP_NUM_THREADS_CY=1

#-----------------------------------------------------------------------------
# Invoke chgres program.
#-----------------------------------------------------------------------------

echo "Starting at: " `date`

${HOMEufs}/ush/chgres_cube.sh

iret=$?
if [ $iret -ne 0 ]; then
  echo "<<< C96 GFS GAUSSIAN NEMSIO TEST FAILED. <<<"
  exit $iret
fi

echo "Ending at: " `date`

#-----------------------------------------------------------------------------
# Compare output from chgres to baseline set of data.
#-----------------------------------------------------------------------------

cd $DATA

test_failed=0
for files in *.nc
do
  if [ -f $files ]; then
    echo CHECK $files
    $NCCMP -dmfqS $files $HOMEreg/baseline_data/c96_gfs_nemsio/$files
    iret=$?
    if [ $iret -ne 0 ]; then
      test_failed=1
    fi
  fi
done

set +x
if [ $test_failed -ne 0 ]; then
  echo "<<< C96 GFS GAUSSIAN NEMSIO TEST FAILED. >>>"
else
  echo "<<< C96 GFS GAUSSIAN NEMSIO TEST PASSED. >>>"
fi

exit 0
