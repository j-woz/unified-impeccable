#!/bin/bash

# #SBATCH -A CHM155_001
# #SBATCH -J p2_s5b
# #SBATCH -o %x-%j.out
# #SBATCH -e %x-%j.err
# #SBATCH -t 1:00:00
# #SBATCH -p batch
# ##SBATCH -q debug
# #SBATCH -N 1
# #SBATCH --tasks-per-node 8
# #SBATCH -S 0

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s5b-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

NAMDBIN=$HOME/proj/uni-impec/namd3_md_example/namd3
export namdargs=''

export ZE_FLAT_DEVICE_HIERARCHY=FLAT

LABEL="S5B"

# Executing runs
for ((i=0; i<$N_COMPS; i=i+4)); do
  for c in {0..3}; do
    lig=$((i+c))
    for ((j=0; j<$n_replicas; j++)); do
      cd $ITR_DIR/$lig/replicas/rep$j/equilibration
      # Minimization
      sed -i "s/nall 10/nall 1/" eq0.conf
      msg eq0.conf
      $NAMDBIN +p6 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log
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
      msg eq1.conf
      $NAMDBIN +p6 +devices 0 $namdargs --tclmain eq1.conf +stdout eq1.log
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
      msg sim1.conf
      $NAMDBIN +p6 +devices 0 $namdargs --tclmain sim1.conf +stdout sim1.log
    done
  done
  wait
done
