#!/bin/bash

# SUB P2 S4D AURORA

#PBS -A IMPECCAFLOW
#PBS -N m4_getenv(NAME)
# Merge streams:
#PBS -o m4_getenv(OUTPUT)
#PBS -j oe
#PBS -l walltime=m4_getenv(WALLTIME)
#PBS -q m4_getenv(QUEUE)
#PBS -l nodes=m4_getenv(NODES):ppn=64
#PBS -l filesystems=home:flare

set -eu

SITE=aurora
LABEL=m4_getenv(NAME)
NODES=m4_getenv(NODES)
PPN=m4_getenv(PPN)

WORKFLOW_STEP=m4_getenv(WORKFLOW_STEP)
cd $WORKFLOW_STEP

source $WORKFLOW_STEP/../impeccable-settings.sh

source $WORKFLOW_STEP/sub_p2_s4d-setup.sh \
       /opt/aurora/25.190.0/oneapi/intel-conda-miniforge \
       /tmp/PY-IMPECCABLE/step4

# Executing runs

MPI_FLAGS=( -n $((NNODES*TASKS_PER_NODE))
           --ppn 64 )

# Ensure Cray MPI
PATH=/opt/cray/pals/1.8/bin:$PATH

LABEL="S4D"
for ((i=0; i<$N_COMPS; i++))
do
  show i N_COMPS
  pwd
  mkdir -pv $ITR_DIR/min/$i/mmpbsa

  assert-exist -v $WORK_DIR/model-inputs/mmpbsa.in \
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
    mpiexec ${MPI_FLAGS[@]} MMPBSA.py.MPI ${MMPBSA_ARGS[@]}
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
