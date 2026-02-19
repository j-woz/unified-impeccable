#!/bin/bash

# #SBATCH -A CHM155_001
# #SBATCH -J p2_s4d
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

source $THIS/sub_p2_s4d-setup.sh \
       /opt/aurora/24.180.3/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/steps123

# Executing runs

MPI_ARGS=( -n $((NNODES*TASKS_PER_NODE))
           --ppn 64 )

# Ensure Cray MPI
PATH=/opt/cray/pals/1.8/bin:$PATH

LABEL="S4D"
for ((i=0; i<$N_COMPS; i++))
do
  show i N_COMPS
  pwd
  mkdir -pv $ITR_DIR/min/$i/mmpbsa

  assert-exists -v $WORK_DIR/model-inputs/mmpbsa.in \
                   $ITR_DIR/min/$i/mmpbsa

  sed "s/START/$f_start/;s/END/$f_end/" $WORK_DIR/model-inputs/mmpbsa.in > \
      $ITR_DIR/min/$i/mmpbsa/mmpbsa.in

  MMPBSA_ARGS=( -i mmpbsa.in
                -sp $ITR_DIR/models/$i/complex.top
                -cp $ITR_DIR/models/$i/com.top
                -rp $ITR_DIR/models/$i/rec.top
                -lp $ITR_DIR/models/$i/lig.top
                -y  $ITR_DIR/min/$i/min.dcd         )

  #ln -s $ITR_DIR/min/$i/mmpbsa $ITR_DIR/min/links/$i
  cd $ITR_DIR/min/$i/mmpbsa
  (
    set -x
    pwd
    which mpiexec
    # mpiexec ${MPI_ARGS[@]} MMPBSA.py.MPI ${MMPBSA_ARGS[@]}
    # mpiexec -n 16 python ~/proj/uni-impec/tests/test-mpi4py.py
    # rm -f reference.frc *.inpcrd *.pdb *.mdin* *.mdcrd*
  )
  cd ..
  msg "sort_poses ..."
  pwd
  bash $WORK_DIR/sort_poses.sh $TASKS_PER_NODE
  msg "sort_poses OK."
  cd ../..
done

# Validating runs
cd $ITR_DIR
python $WORK_DIR/validate_4.py -s $N_COMPS
