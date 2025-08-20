#!/bin/bash
set -eu

# SUBMIT FRONTIER

THIS=$( dirname $0 )

set -x
sbatch $THIS/sub_p1_s2.sh
