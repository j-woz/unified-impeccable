#!/bin/bash
set -eu

THIS=$( dirname $0 )

set -x
sbatch $THIS/sub_p2_s4a-frontier.sh
