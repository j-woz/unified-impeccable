#!/bin/bash
set -eu

# CLEAN ERRORS

THIS=$( dirname $( realpath $0 ) )
source $THIS/../utils.sh

LABEL="clean-errors.sh"

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
find $WORK_DIR -name ERROR | xargs -n 8 rm -v
time-report
