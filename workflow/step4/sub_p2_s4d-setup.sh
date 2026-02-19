
# SUB P2 S4D SETUP

if (( ${#*} != 2 ))
then
  echo "sub_p2_s4b-setup: " \
       "Provide CONDA_INSTALLATION CONDA_ENVIRONMENT!"
  return 1
fi

CONDA_INSTALLATION=$1
CONDA_ENVIRONMENT=$2

source $WORKFLOW_DIR/utils.sh

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh \
       $CONDA_INSTALLATION $CONDA_ENVIRONMENT

CODE_DIR=$IMPECCABLE_CODE/pose_generation
WORK_DIR=$WORK_TOP/step4
cp -ru $CODE_DIR/* $WORK_DIR/

# Setting paths
WORK_DIR=$WORK_TOP/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER

# Setting runs
cd $ITR_DIR
#mkdir -p min/links
f_start=1
POSES=100
f_end=$POSES
NNODES=1
TASKS_PER_NODE=1

sed -i "s/{0..\$ndir}\///g; s/mdout.0/mdout.{0..\$ndir}/g" $WORK_DIR/sort_poses.sh
