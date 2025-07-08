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

# Setting paths
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR

# Setting runs
cd $ITR_DIR
N_COMPS=50

# Executing runs
for ((i=0; i<$N_COMPS; i++)); do
	mkdir -p min/$i
	cd min/$i
	sed "s/LIG/$i/g" $WORK_DIR/model-inputs/eq0.conf > eq0.conf
	#sed -i "s/minimize 200/minimize 100/" eq0.conf
	#sed -i "s/dcdfreq             200/dcdfreq             100/" eq0.conf
	#srun -N1 -n1 -c56 $NAMDBIN --tclmain eq0.conf +stdout eq0.log
	srun -N1 -n1 -c56 --ntasks-per-node=1 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0 $NAMDBIN +p56 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log
	cd ../..
done

