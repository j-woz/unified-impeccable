#!/bin/bash

# SUB P1 S1 AURORA
# Aurora-specific launch of step tasks

#PBS -A workflow_scaling
#PBS -N p1_s1
# Merge streams:
#PBS -o sub_p1_s1.out
#PBS -j oe
#PBS -l walltime=20:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare


THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

module load frameworks/2024.2.1_u1

set -eu
source $THIS/../impeccable-settings.sh

source $THIS/sub_p1_s1-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123
#        /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
#

(
  set -x
  which mpiexec
  pwd -P
  /usr/bin/time --format="TIME: %E" \
                mpiexec -n 64 \
                python $WORK_DIR/docking_openeye.py
  # DB INSERT "sub_p1_s1/docking" OK;
)

# Validating runs
(
  VALIDATE_ARGS=( -s $MEM_DIR/scores -c config_htp.json )

  set -x

  cd $MEM_DIR
  pwd -P
  /usr/bin/time --format="TIME: %E" \
                python $WORK_DIR/validate_1.py ${VALIDATE_ARGS[@]}
  # DB INSERT "sub_p1_s1/validate" OK;
)

echo $0 OK
