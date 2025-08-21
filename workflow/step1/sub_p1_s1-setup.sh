#!/bin/bash

# SUB P1 S1 SETUP
# Portable setup script
# Assumes SITE is in the environment

set -eu

#THIS=$( realpath $( dirname $0 ) )
source /lustre/orion/chm155/proj-shared/ketan2/unified-impeccable/workflow/setup-${SITE:-UNKNOWN}.sh

# Setting paths
CODE_DIR=$IMPECCABLE_CODE/htp_docking
export WORK_DIR=$WORK_TOP/step1
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $MEM_DIR
mkdir -p lig_confs
mkdir -p scores

echo "m4 generating:" $MEM_DIR/config_htp.json
m4 -P /lustre/orion/chm155/proj-shared/ketan2/unified-impeccable/workflow/common.m4 /lustre/orion/chm155/proj-shared/ketan2/unified-impeccable/workflow/step1/config_htp.json > $MEM_DIR/config_htp.json

NNODES=1
TASKS_PER_NODE=64

