#!/bin/bash
set -eu

THIS=$( dirname $0 )

set -x
sbatch $THIS/sub_p1_s2.sh
