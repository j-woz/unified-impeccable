
# SUB P2 S4B SETUP

CONDA_ENVIRONMENT=$1
source $THIS/../site-${SITE:-UNKNOWN}-settings.sh $CONDA_ENVIRONMENT

# Setting paths
export WORK_DIR=$WORK_TOP/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER
mkdir -p $ITR_DIR

# Setting runs
cd $ITR_DIR
N_COMPS=50
