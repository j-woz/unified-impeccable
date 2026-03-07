#!/bin/bash
set -eu

# SUBMIT AURORA
# THIS DOES NOT WORK WITH IMPECC-JOB

THIS=$( dirname $0 )
cd $THIS
export WORKFLOW_STEP=$( realpath $PWD )

source ../utils.sh

set -x
impecc-job qsub sub_p1_s1-aurora.sh job-settings.sh
