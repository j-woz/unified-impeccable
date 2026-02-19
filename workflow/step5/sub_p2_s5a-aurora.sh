#!/bin/bash

# SUB P2 S5A AURORA

#PBS -A workflow_scaling
#PBS -N p2_s4c
# Merge streams:
#PBS -o sub_p2_s4c.out
#PBS -j oe
#PBS -l walltime=0:05:00
#PBS -q debug
#PBS -l nodes=1:ppn=64
#PBS -l filesystems=home:flare

# #SBATCH -A CHM155_001
# #SBATCH -J p2_s5a
# #SBATCH -o %x-%j.out
# #SBATCH -e %x-%j.err
# #SBATCH -t 1:00:00
# #SBATCH -p batch
# ##SBATCH -q debug
# #SBATCH -N 1
# #SBATCH --tasks-per-node 64
# #SBATCH -S 0

set -eu

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s5a-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

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
