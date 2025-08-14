#!/bin/bash

# SUB P1 S1 AURORA

#PBS -A workflow_scaling
#PBS -N p1_s1
# Merge streams:
#PBS -o sub_p1_s1.out
#PBS -j oe
#PBS -l walltime=20:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare

set -eu

THIS=$PBS_O_WORKDIR
cd $THIS

source $THIS/../python-aurora.sh
source $THIS/../sfw-aurora.sh
source $THIS/../sfw-user.sh
source $THIS/../settings.sh
source $THIS/sub_p1_s1-setup.sh

(
  set -x
  pwd -P
  mpiexec -n 64 /usr/bin/time --format="TIME: %E" \
        python $WORK_DIR/docking_openeye.py
  # DB INSERT "sub_p1_s1/docking" OK;
)

# Validating runs
(
  set -x

  cd $MEM_DIR
  pwd -P
  VALIDATE_ARGS=( -s $MEM_DIR/scores -c config_htp.json )
  /usr/bin/time --format="TIME: %E" \
                python $WORK_DIR/validate_1.py ${VALIDATE_ARGS[@]}
  # DB INSERT "sub_p1_s1/validate" OK;
)

echo $0 OK
