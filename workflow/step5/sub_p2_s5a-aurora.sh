#!/bin/bash

# SUB P2 S5A AURORA

#PBS -A IMPECCAFLOW
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=64
#PBS -l filesystems=home:flare

set -eu

export SITE=aurora
LABEL=m4_getenv(NAME)
NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

source $WORKFLOW_STEP/../impeccable-settings.sh
source $WORKFLOW_STEP/sub_p2_s5a-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step4

# Executing runs
cd $ITR_DIR
#l=0
for ((i=0; i<$N_COMPS; i++))
do
  bash $WORK_DIR/p2_s5a_process.sh $i &
  sleep 0.2
  jobs
done

LABEL="S5A"
if wait
then
  msg "SUCCESS."
else
  msg "FAILED."
fi
