#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p1_s1
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0


# Setting environments
module reset
export PATH=$PATH:/lustre/orion/chm155/proj-shared/openeye/arch/redhat-RHEL8-x64/quacpac:/lustre/orion/chm155/proj-shared/openeye/bin
export OE_LICENSE=/ccs/proj/chm155/IMPECCABLE/High-Throughput-Docking/oe_license.txt
source /ccs/proj/chm155/IMPECCABLE/activate_conda.sh
conda activate oepython_new

# Setting paths
CODE_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/htp_docking
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step1
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
sed -i "s/\.\/input/\.\.\/input/g" config_htp.json
NNODES=1
TASKS_PER_NODE=64

# Executing runs
srun -N ${NNODES} -n $((NNODES*TASKS_PER_NODE)) -S 0 --ntasks-per-node=64 python $WORK_DIR/docking_openeye.py

# Validating runs
cd $MEM_DIR
python $WORK_DIR/validate_1.py -s ./scores -c config_htp.json

