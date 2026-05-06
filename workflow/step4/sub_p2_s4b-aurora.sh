#!/bin/bash

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

SITE=aurora
LABEL=m4_getenv(NAME)
NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

source $WORKFLOW_STEP/../impeccable-settings.sh
source $WORKFLOW_STEP/sub_p2_s4b-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step4

cp $WORKFLOW_STEP/p2_s4b_process.sh $WORK_DIR

# Create directory structure
# Parameterise and build models
for ((i=0; i < $N_COMPS; i++))
do
  bash $WORK_DIR/p2_s4b_process.sh $i $ITR_DIR $WORK_DIR &
  sleep 0.2
done

wait
