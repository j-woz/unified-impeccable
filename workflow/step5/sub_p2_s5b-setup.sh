
# SUB P2 S5B SETUP

if (( ${#*} != 2 ))
then
  echo "sub_p2_s5b-setup: " \
       "Provide CONDA_INSTALLATION CONDA_ENVIRONMENT!"
  return 1
fi

CONDA_INSTALLATION=$1
CONDA_ENVIRONMENT=$2

source $WORKFLOW_DIR/utils.sh

source $THIS/../site-${SITE:-UNKNOWN}-settings.sh \
       $CONDA_INSTALLATION $CONDA_ENVIRONMENT

# Setting paths
CODE_DIR=$IMPECCABLE_CODE/pose_generation
WORK_DIR=$WORK_TOP/step5

MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER

# Setting runs
n_replicas=2
