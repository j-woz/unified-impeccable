#!/bin/bash
set -eu

tstamp() {
  date +"%Y-%m-%d_%H%M%S"
}

# Setup steps:
# git clone git@github.com:mpi4py/mpi4py.git
# cd mpi4py
# git checkout 4.1.1
# git submodule sync && git submodule update --init --recursive

TMP_WORK=/tmp/wozniak/mpi4py
mkdir -pv $TMP_WORK

module load oneapi

export CC=$(which mpicc)
echo "CC = $CC"
export CXX=$(which mpicxx)
echo "CXX = $CXX"

export REL_WITH_DEB_INFO=1

python setup.py clean --all

# CC=$(which mpicc) CXX=$(which mpicxx)
python setup.py bdist_wheel --dist-dir ${TMP_WORK} 2>&1 | \
  tee ${TMP_WORK}/"mpi4py-build-whl-$(tstamp).log"
echo "Finished building mpi4py/4.1.1, with oneapi/2025.3.1"

LOCAL_WHEEL_LOC=${TMP_WORK}
pip install --no-deps --no-cache-dir --force-reinstall $LOCAL_WHEEL_LOC/mpi4py-*.whl 2>&1 | \
  tee ${TMP_WORK}/"mpi4py-install-$(tstamp).log"
echo "Finished installing the wheel and dependencies"
