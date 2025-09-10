
# SUB P2 S4D SETUP

CONDA_ENVIRONMENT=$1
source $THIS/../site-${SITE:-UNKNOWN}-settings.sh $CONDA_ENVIRONMENT

# Setting paths
WORK_DIR=$WORK_TOP/step4
MEM_ID=0
MEM_DIR=$WORK_DIR/mem$MEM_ID
ITER=0 # p2: 0, p3: >=1
ITR_DIR=$MEM_DIR/itr$ITER

# Setting runs
cd $ITR_DIR
#mkdir -p min/links
N_COMPS=50
f_start=1
POSES=100
f_end=$POSES
NNODES=1
TASKS_PER_NODE=32
sed -i "s/{0..\$ndir}\///g; s/mdout.0/mdout.{0..\$ndir}/g" $WORK_DIR/sort_poses.sh
