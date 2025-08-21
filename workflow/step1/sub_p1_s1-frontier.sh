#!/bin/bash

# SUB P1 S1 FRONTIER

#SBATCH -A chm155_004
#SBATCH -J p1_s1
# Merge streams:
#SBATCH -o %x-%j.out
#SBATCH -e %x-%j.out
#SBATCH -t 20:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 1
#SBATCH --tasks-per-node 64
#SBATCH -S 0

<<<<<<< Updated upstream
THIS=$( realpath $( dirname $0 ) )
cd $THIS
=======
#THIS=$( realpath $( dirname $0 ) )
#cd $THIS
>>>>>>> Stashed changes

export SITE=frontier

source /lustre/orion/proj-shared/chm155/ketan2/unified-impeccable/workflow/setup-$SITE.sh
source /lustre/orion/proj-shared/chm155/ketan2/unified-impeccable/workflow/settings.sh
source /lustre/orion/proj-shared/chm155/ketan2/unified-impeccable/workflow/step1/sub_p1_s1-setup.sh

# Executing runs
SRUN_ARGS=(
  -N ${NNODES}
  -n $((NNODES*TASKS_PER_NODE))
  -S 0
  --ntasks-per-node=64
)

(
  set -x
  pwd -P
  ls
  /usr/bin/time --format="TIME: %E" \
        srun ${SRUN_ARGS[@]} python $WORK_DIR/docking_openeye.py
  # DB INSERT "sub_p1_s1/docking" OK;
)

# Validating runs
(
  set -x

  cd $MEM_DIR
  pwd -P
  ls
  /usr/bin/time --format="TIME: %E" \
                python $WORK_DIR/validate_1.py -s $CODE_DIR/scores -c config_htp.json
  # DB INSERT "sub_p1_s1/validate" OK;

)

echo $0 OK
