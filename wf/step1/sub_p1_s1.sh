#!/bin/bash

# Frontier version - needs to be split up

#SBATCH -A chm155_004
#SBATCH -J p1_s1
# Merge streams:
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.out
#SBATCH -t 20:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

set -x
set -eu

# Setting paths
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
mkdir -p $MEM_DIR

# Setting runs
cp -r $CODE_DIR/* $WORK_DIR/
cd $MEM_DIR
mkdir -p lig_confs
mkdir -p scores
cp $WORK_DIR/config_htp.json $MEM_DIR
sed -i "s/ZIN/BDB/g" config_htp.json
sed -i "s/1000000/1000/g" config_htp.json
sed -i "s@PLACEHOLDER_DIR/input@${WORK_DIR}/input@g" config_htp.json
NNODES=1
TASKS_PER_NODE=64

# Executing runs
SRUN_ARGS=(
  -N ${NNODES}
  -n $((NNODES*TASKS_PER_NODE))
  -S 0
  --ntasks-per-node=64
)

(
  set -x
  pwd -P
  ls
  /usr/bin/time --format="TIME: %E" \
        srun ${SRUN_ARGS[@]} python $WORK_DIR/docking_openeye.py
  # DB INSERT "sub_p1_s1/docking" OK;
)

# Validating runs
(
  set -x

  cd $MEM_DIR
  pwd -P
  ls
  /usr/bin/time --format="TIME: %E" \
                python $WORK_DIR/validate_1.py -s $CODE_DIR/scores -c config_htp.json
  # DB INSERT "sub_p1_s1/validate" OK;

)

echo $0 OK
