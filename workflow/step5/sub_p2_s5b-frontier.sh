#!/bin/bash

#SBATCH -A CHM155_001
#SBATCH -J p2_s5b
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.err
#SBATCH -t 1:00:00
#SBATCH -p batch
##SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 8
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
WORK_DIR=/lustre/orion/chm155/proj-shared/apbhati/IMPECCABLE_2.0/DEBUG_RUN/step5
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER

# Setting runs
N_COMPS=50
n_replicas=2

# Executing runs
for ((i=0; i<$N_COMPS; i=i+4)); do
	for c in {0..3}; do
	lig=$((i+c))
	for ((j=0; j<$n_replicas; j++)); do
		cd $ITR_DIR/$lig/replicas/rep$j/equilibration
		# Minimization
		sed -i "s/nall 10/nall 1/" eq0.conf
		srun -N1 -n1 -c7 --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0 $NAMDBIN +p6 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log &
	done
	done
	wait
done

for ((i=0; i<$N_COMPS; i=i+4)); do
	for c in {0..3}; do
	lig=$((i+c))
	for ((j=0; j<$n_replicas; j++)); do
		cd $ITR_DIR/$lig/replicas/rep$j/equilibration
		# Equilibration
		sed -i "s/run 500000/run 20000/" eq1.conf
		sed -i "s/500000/10000/" eq1.conf # restartfreq
		srun -N1 -n1 -c7 --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0 $NAMDBIN +p6 +devices 0 $namdargs --tclmain eq1.conf +stdout eq1.log &
	done
	done
	wait
done

for ((i=0; i<$N_COMPS; i=i+4)); do
	for c in {0..3}; do
	lig=$((i+c))
	for ((j=0; j<$n_replicas; j++)); do
		cd $ITR_DIR/$lig/replicas/rep$j/simulation
		# Simulation
		sed -i "s/2000000/20000/" sim1.conf
		sed -i "s/500000/10000/" sim1.conf # restartfreq
		srun -N1 -n1 -c7 --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest --mpi=none --kill-on-bad-exit=0 $NAMDBIN +p6 +devices 0 $namdargs --tclmain sim1.conf +stdout sim1.log &
	done
	done
	wait
done
