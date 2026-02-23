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

PATH=$HOME/proj/uni-impec/namd_minimize_example:$PATH
NAMD=namd2
export namdargs=''

export ZE_FLAT_DEVICE_HIERARCHY=FLAT

LABEL="S5B"

VG=( /lus/flare/projects/workflow_scaling/wozniak/sfw/Miniconda/312-Main/bin/valgrind
     --leak-check=no )

# # Executing runs
# for ((i=0; i<$N_COMPS; i=i+4)); do
#   for c in {0..3}; do
#     lig=$((i+c))
#     for ((j=0; j<$n_replicas; j++)); do
#       cd $ITR_DIR/$lig/replicas/rep$j/equilibration
#       # Minimization : Requires NAMD2 on Aurora
#       sed -i "s/nall 10/nall 1/" eq0.conf
#       msg eq0.conf : i=$i c=$c j=$j
#       $NAMDBIN +p6 +devices 0 $namdargs --tclmain eq0.conf +stdout eq0.log
#     done
#   done
#   wait
# done

PATH=$HOME/proj/uni-impec/namd3_md_example:$PATH
NAMD=namd3

# for ((i=0; i<$N_COMPS; i=i+4)); do
#   for c in {0..3}; do
#     lig=$((i+c))
#     for ((j=0; j<$n_replicas; j++)); do
#       echo
#       cd $ITR_DIR/$lig/replicas/rep$j/equilibration
#       msg i=$i c=$c j=$j
#       pwd
#       # Equilibration
#       sed -i "s/run 500000/run 1000/" eq1.conf
#       sed -i "s/500000/10000/" eq1.conf # restartfreq
#       sed -i "s/# CUDA/CUDA/" eq1.conf
#       if ! grep -q "margin 0.0" eq1.conf
#       then
#         sed -i "/run/imargin 0.0" eq1.conf
#       fi
#       namd-catch eq1.conf eq1.log
#       # +p6 +devices 0
#     done
#   done
#   wait
# done

echo
msg "NAMD Equilibration done."
echo

for ((i=0; i<$N_COMPS; i=i+4)); do
  for c in {0..3}; do
    lig=$((i+c))
    for ((j=0; j<$n_replicas; j++)); do
      cd $ITR_DIR/$lig/replicas/rep$j/simulation
      msg i=$i c=$c j=$j
      pwd
      # Simulation
      sed -i "s/2000000/20000/" sim1.conf
      sed -i "s/500000/10000/" sim1.conf # restartfreq
      msg sim1.conf
      namd-margin-0 sim1.conf
      namd-catch sim1.conf sim1.log
      # $NAMDBIN +p6 +devices 0 $namdargs --tclmain sim1.conf +stdout sim1.log
      echo
    done
  done
  wait
done
