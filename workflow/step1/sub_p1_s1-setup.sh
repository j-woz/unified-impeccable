#!/bin/bash

# SUB P1 S1 SETUP
# Portable application setup script
# Assumes SITE, THIS in the environment
# Sets WORK_DIR, MEM_DIR

set -eu

source $THIS/../setup-${SITE:-UNKNOWN}.sh

# Setting paths
CODE_DIR=$IMPECCABLE_CODE/htp_docking
export WORK_DIR=$WORK_TOP/step1
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $MEM_DIR
mkdir -pv lig_confs
mkdir -pv scores

echo "sub_p1_s1-setup: CODE_DIR:  " $WORK_DIR
echo "sub_p1_s1-setup: WORK_DIR:  " $WORK_DIR
echo "sub_p1_s1-setup: MEM_DIR:   " $MEM_DIR
echo "sub_p1_s1-setup: m4 writing:" $MEM_DIR/config_htp.json
# m4 -P /lustre/orion/chm155/proj-shared/ketan2/unified-impeccable/workflow/common.m4 /lustre/orion/chm155/proj-shared/ketan2/unified-impeccable/workflow/step1/config_htp.json > $MEM_DIR/config_htp.json

m4 -P $THIS/../common.m4 $THIS/config_htp.json > $MEM_DIR/config_htp.json

NNODES=1
TASKS_PER_NODE=64

