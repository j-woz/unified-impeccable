#!/bin/bash

# SUB P2 S4B AURORA

#PBS -A IMPECCAFLOW
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=m4_getenv(PPN)
#PBS -l filesystems=home:flare

set -eu

SITE=aurora
NAME=m4_getenv(NAME)
LABEL=$NAME
export NODES=m4_getenv(NODES)
export PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

echo "JOB:" $PBS_JOBID

source $WORKFLOW_STEP/../utils.sh

SETTINGS_IMPECCABLE=m4_getenv(SETTINGS_IMPECCABLE)
source-checked $SETTINGS_IMPECCABLE

source $WORKFLOW_STEP/sub_p2_s4b-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step4

LABEL=$NAME

msg "s4b-aurora ..."

# Copy in application script
# Remove the target because of occasional "text file in use" errors
#        on Aurora: 2026-06-03
bak   $WORK_DIR/p2_s4b_process.sh
cp    $WORKFLOW_STEP/p2_s4b_process.sh $WORK_DIR
chmod u+x $WORK_DIR/p2_s4b_process.sh
PATH=$WORK_DIR:$PATH

# This may be left over from a prior run:
bak $WORK_DIR/p2_s4b_process.list

msg "writing: $WORK_DIR/p2_s4b_process.list"
for ((i=0; i < $N_COMPS; i++))
do
  # bash $WORK_DIR/p2_s4b_process.sh $i $ITR_DIR $WORK_DIR &
  # sleep 0.1
  echo $i $ITR_DIR $WORK_DIR
done >> $WORK_DIR/p2_s4b_process.list

SWIFT=/lus/flare/projects/IMPECCAFLOW/sfw/swift-t_2026-05-14
PATH=$SWIFT/stc/bin:$SWIFT/turbine/bin:$PATH
PATH=/opt/cray/pals/1.8/bin:$PATH

cp -v $WORKFLOW_STEP/p2_s4b_process.swift $WORK_DIR

cd $WORK_DIR

(
  set -x
  stc p2_s4b_process.swift
)

time-start

(
  set -x
  # PPN should be automatic:
  export TURBINE_APP_DEBUG=1
  mpiexec -n $PROCS turbine-pilot p2_s4b_process.tic p2_s4b_process.list
)

time-report
