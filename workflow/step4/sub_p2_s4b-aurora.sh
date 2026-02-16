#!/bin/bash

#PBS -A workflow_scaling
#PBS -N p2_s4a
# Merge streams:
#PBS -o sub_p2_s4.out
#PBS -j oe
#PBS -l walltime=0:05:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare

# #SBATCH -A CHM155_001
# #SBATCH -J p2_s4b
# #SBATCH -o %x-%j.out
# #SBATCH -e %x-%j.err
# #SBATCH -t 1:00:00
# #SBATCH -p batch
# #SBATCH -q debug
# #SBATCH -N 1
# #SBATCH --tasks-per-node 64
# #SBATCH -S 0

set -eu

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4b-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

cp $THIS/p2_s4b_process.sh $WORK_DIR

# Create directory structure
# Parameterise and build models
for ((i=0; i < $N_COMPS; i++)); do
	bash $WORK_DIR/p2_s4b_process.sh $i $ITR_DIR $WORK_DIR &
 	sleep 0.2
done

wait
