#!/bin/bash

# INSTALL CONDA PKGS SH
# User can tar this Anaconda installation for faster reuse
#   See python-aurora.sh

# Install OpenEye by copying from Frontier

CHANNELS=( -c conda-forge
           -c openeye
         )

# Installation steps12:
# try module frameworks/2024.2.1_u1 in /opt/aurora/24.180.3
PKGS_CONDA_123=(
  pydantic-settings
  openeye-toolkits
  # 1
  rdkit
  # 2
  horovod keras tensorflow IPython
  # 3
  mpi4py
)
PKGS_PIP_123=( SmilesPE )

# Installation step4a:
PKGS_OPENEYE=(
  pydantic-settings
  openeye-toolkits
  # Step 4a:
  mdanalysis
)
# Installation step4b:
# Works with all in frameworks/2024
PKGS_AMBER=(
  ambertools
)

conda install ${CHANNELS[@]} ${PKGS[@]}

# REINVENT
# Needs its own environment, conflicts with learning libraries
git clone git@github.com:MolecularAI/REINVENT4.git
conda create --yes -p /tmp/PY-IMPECCABLE/step6
conda activate /tmp/PY-IMPECCABLE/step6
cd REINVENT4
# Approach 1: Works but installs to ~/.local
python install.py cpu
PATH=$HOME/.local/aurora/frameworks/2024.2.1_u1/bin:$PATH
# Approach 2: Works
python3 -m venv /tmp/PY-IMPECCABLE/step6/venv_reinvent --system-site-packages
source /tmp/PY-IMPECCABLE/step6/venv_reinvent/bin/activate
python install.py cpu
