#!/bin/bash

# SUB P1 S2 AURORA

#PBS -A workflow_scaling
#PBS -N p1_s2
# Merge streams:
#PBS -o sub_p1_s2.out
#PBS -j oe
#PBS -l walltime=1:00:00
#PBS -q debug
#PBS -l nodes=1:ppn=8
#PBS -l filesystems=home:flare

set -eu

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p1_s2-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=./miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
mkdir -pv $MIOPEN_USER_DB_PATH

# Executing runs
set -x
hostname
python3 $WORK_DIR/smiles_regress_transformer_run.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_2.py
