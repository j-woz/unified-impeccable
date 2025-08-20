#!/bin/bash

# SUB P1 S1 AURORA

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

THIS=$PBS_O_WORKDIR
cd $THIS

export SITE=aurora

source $THIS/../setup-$SITE.sh
source $THIS/../settings.sh
source $THIS/sub_p1_s2-setup.sh

# source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
# conda activate st_train

export TF_FORCE_GPU_ALLOW_GROWTH=true
export MIOPEN_USER_DB_PATH=./miopen-cache
export MIOPEN_CUSTOM_CACHE_DIR=$MIOPEN_USER_DB_PATH
mkdir -p $MIOPEN_USER_DB_PATH

# Executing runs
set -x
hostname
python3 $WORK_DIR/smiles_regress_transformer_run.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_2.py
