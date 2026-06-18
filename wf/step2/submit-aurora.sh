#!/bin/bash
set -eu

THIS=$( dirname $0 )

# cd to THIS to for correct PBS_O_WORKDIR
cd $THIS
source ../utils.sh
bak sub_p1_s2.out

set -x
qsub $THIS/sub_p1_s2-aurora.sh
