#!/bin/bash

# SUB PS S5B AURORA

# #SBATCH -A CHM155_001
# #SBATCH -J p2_s5c
# #SBATCH -o %x-%j.out
# #SBATCH -e %x-%j.err
# #SBATCH -t 1:00:00
# #SBATCH -p batch
# ##SBATCH -q debug
# #SBATCH -N 1
# #SBATCH --tasks-per-node 64
# #SBATCH -S 0

THIS=$( realpath $( dirname $0 ) )
cd $THIS

export SITE=aurora

source $THIS/../impeccable-settings.sh
source $THIS/sub_p2_s5c-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

# Executing runs
for ((i=0; i<$N_COMPS; i++))
do
  for ((j=0; j<$n_replicas; j++))
  do
    cd $ITR_DIR/$i/replicas/rep$j/simulation/mmpbsa

    MMPBSA_ARGS=( -i mmpbsa.in
              -sp $ITR_DIR/$i/build/complex.top
              -cp $ITR_DIR/$i/build/com.top
              -rp $ITR_DIR/$i/build/rec.top
              -lp $ITR_DIR/$i/build/lig.top
              -y ../sim1.dcd )

    (
      set -x
      pwd

      mpiexec -n $TASKS_PER_NODE MMPBSA.py.MPI ${MMPBSA_ARGS[@]}
    )
    rm -f reference.frc *.inpcrd *.pdb *.mdin* *.mdcrd*
  done
done

# Post processing
cd $ITR_DIR
bash $WORK_DIR/esmacs_analysis.sh $N_COMPS $WORK_DIR/input $STEP4_DIR

# Validating runs
python $WORK_DIR/validate_5.py -d $N_COMPS
