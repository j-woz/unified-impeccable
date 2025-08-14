
# PYTHON AURORA
# source this to setup Python on Aurora

if [[ ! -e /tmp/TF ]]
then
  # TAR=/lus/flare/projects/candle_aesp_CNDA/sfw/TF.tar
  TAR=~/W/wozniak/conda-tgz/TF-IMPECCABLE.tar
  echo "extracting $TAR ..."
  tar xf $TAR -C /tmp
  echo "extracted."
fi

# These functions trigger errors:
set +eu
module load frameworks
conda activate /tmp/TF
set -eu
