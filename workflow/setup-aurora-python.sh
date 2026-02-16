
# SETUP AURORA PYTHON
# source this to setup Python on Aurora
# Apply set +eu beforehand because conda.sh and module-load can have
#               extraneous internal errors

LABEL="setup-aurora-python"

msg start ...

# Top-level directory under which are all conda environments
CONDA_TARGET=/tmp/PY-IMPECCABLE

# ENVIRONMENT_TAR=/lus/flare/projects/candle_aesp_CNDA/sfw/TF.tar
ENVIRONMENT_TAR=~/W/wozniak/conda-tgz/PY-IMPECCABLE.tar

if [[ ! -e $CONDA_TARGET ]]
then
  msg "extracting $ENVIRONMENT_TAR ..."
  if command time --format="TIME: %E" tar xf $ENVIRONMENT_TAR -C /tmp
  then
    msg "extracted."
  else
    msg "extraction failed!"
    return 1
  fi
fi

# Now doing this in site-SITE-settings
# # These functions trigger errors:
# echo "$LABEL: module load frameworks..."
# # This source suppresses warnings about conda deactivate:
# source /opt/aurora/24.347.0/oneapi/intel-conda-miniforge/etc/profile.d/conda.sh
# module load frameworks
# echo "$LABEL: activating anaconda..."
# conda activate $CONDA_ENVIRONMENT
