
# SETUP AURORA PYTHON
# source this to setup Python on Aurora

LABEL="setup-aurora-python"

msg start ...

# Top-level directory under which are all conda environments
CONDA_TARGET=/tmp/PY-IMPECCABLE

ENVIRONMENT_TAR=/lus/flare/projects/IMPECCAFLOW/wozniak/conda-tar/PY-IMPECCABLE.tar

if [[ ! -e $CONDA_TARGET ]]
then
  show -c NODES
  msg "extracting $ENVIRONMENT_TAR ..."
  if command time --format="TIME: %E"       \
             mpiexec -n $NODES --ppn 1      \
             tar xf $ENVIRONMENT_TAR -C /tmp
  then
    msg "extracted."
  else
    msg "extraction failed!"
    return 1
  fi
fi
