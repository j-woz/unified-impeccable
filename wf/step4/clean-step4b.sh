#!/bin/bash
set -eu

# CLEAN

THIS=$( dirname $( realpath $0 ) )
source $THIS/../utils.sh

LABEL="clean.sh"

if (( ${#} != 1 ))
then
  crash "provide a WORK_DIR!"
fi

WORK_DIR=$1

if [[ $( basename $WORK_DIR ) != "step4" ]]
then
  crash "WORK_DIR should be a step4!"
fi

assert-exist $WORK_DIR

time-start
rm -r $WORK_DIR/models              \
      $WORK_DIR/par-gen
time-report
