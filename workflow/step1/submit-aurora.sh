#!/bin/bash
set -eu

# SUBMIT AURORA

THIS=$( dirname $0 )
# cd to THIS to for correct PBS_O_WORKDIR
cd $THIS

source ../utils.sh
bak sub_p1_s1.out

set -x
qsub sub_p1_s1-aurora.sh
