#!/bin/bash

# INSTALL CONDA PKGS SH
# User can tar this Anaconda installation for faster reuse
#   See python-aurora.sh

# Install OpenEye by copying from Frontier

CHANNELS=( -c conda-forge
           -c openeye
         )

# Installation steps123:
PKGS_CONDA_123=(
  pydantic-settings
  openeye-toolkits
  # 1
  rdkit
  # 2
  horovod keras tensorflow IPython
)
PKGS_PIP_123=(
  SmilesPE
)

# Installation step4a:
PKGS_OPENEYE=( pydantic-settings
       openeye-toolkits
       # Step 4a:
       mdanalysis
     )
# Installation step4b:
# In a blank env:
PKGS_AMBER=(
  ambertools
)

conda install ${CHANNELS[@]} ${PKGS[@]}
