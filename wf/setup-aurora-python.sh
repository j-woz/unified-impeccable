
# SETUP AURORA PYTHON
# source this to setup Python on Aurora

LABEL_OLD=$LABEL
LABEL="setup-aurora-python"

msg start ...

# Top-level directory under which are all conda environments
CONDA_TARGET=/tmp/PY-IMPECCABLE

ENVIRONMENT_TAR=/lus/flare/projects/IMPECCAFLOW/wozniak/conda-tar/PY-IMPECCABLE.tar

# # Plain mpiexec approach
# if [[ ! -e $CONDA_TARGET ]]
# then
#   show -c NODES
#   msg "extracting $ENVIRONMENT_TAR ..."
#   if command time --format="TIME: %E"       \
#              mpiexec -n $NODES --ppn 1      \
#              tar xf $ENVIRONMENT_TAR -C /tmp
#   then
#     msg "extracted."
#   else
#     msg "extraction failed!"
#     LABEL=$LABEL_OLD
#     return 1
#   fi
# fi

# mpi-cp approach
module load oneapi mpich
PATH=/lus/flare/projects/IMPECCAFLOW/sfw/swift-t_2026-05-14/turbine/bin:$PATH
if [[ ! -e $CONDA_TARGET ]]
then
  # show -c NODES
  msg "copying $ENVIRONMENT_TAR ..."
  if mpiexec -n $NODES --ppn 1 \
             mpi-cp $ENVIRONMENT_TAR /tmp
  then
    msg "copied."
  else
    msg "copy failed!"
    LABEL=$LABEL_OLD
    return 1
  fi
  ENVIRONMENT_FILE=$( basename $ENVIRONMENT_TAR )
  msg "extracting $ENVIRONMENT_FILE ..."
  pushd /tmp > /dev/null
  if command time --format="TIME: %E"        \
             mpiexec -n $NODES --ppn 1       \
             tar xf $ENVIRONMENT_FILE
  then
    msg "extracted."
  else
    msg "extraction failed!"
    popd > /dev/null
    LABEL=$LABEL_OLD
    return 1
  fi
  popd > /dev/null
fi

msg done.
LABEL=$LABEL_OLD
