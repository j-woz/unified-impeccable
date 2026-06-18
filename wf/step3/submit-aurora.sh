#!/bin/bash
set -eu

THIS=$( dirname $0 )

set -x
qsub $THIS/sub_p1_s3-aurora.sh
