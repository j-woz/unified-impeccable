#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s4c
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
##SBATCH -q debug
#SBATCH -N 1
##SBATCH --tasks-per-node 64
#SBATCH -S 0

export THIS=$SLURM_SUBMIT_DIR
cd $THIS

export SITE=frontier

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s4c-setup.sh AmberTools23_Frontier-Balint

# Setting environments
module reset
module load PrgEnv-gnu
module load rocm/6.2.4
module load cray-fftw
module load craype-accel-amd-gfx90a
export NAMDBINDIR=/lustre/orion/stf006/world-shared/dilipa/NAMD/NAMD31A3
export NAMDVER=NAMD_3.1alpha3_Linux-x86_64-multicore-HIP
export NAMDBIN=$NAMDBINDIR/$NAMDVER/namd3
export namdargs=''

# Executing runs
set -eux
for ((i=0; i < $N_COMPS; i++)); do
	mkdir -p min/$i
	cd min/$i
	sed "s/LIG/$i/g" $WORK_DIR/model-inputs/eq0.conf > eq0.conf
	#sed -i "s/minimize 200/minimize 100/" eq0.conf
	#sed -i "s/dcdfreq             200/dcdfreq             100/" eq0.conf
	#srun -N1 -n1 -c56 $NAMDBIN --tclmain eq0.conf +stdout eq0.log
	srun -N1 -n1 -c56 --ntasks-per-node=1 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0 $NAMDBIN +p56 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log
	cd ../..
done
