
# UTILS
# General-purpose shell programming utilities

bak()
# Move given file to numbered backup
# If file does not exist, nothing to backup, no problem.
{
  if (( ${#} != 1 ))
  then
    echo "bak(): provide FILE!"
    return 1
  fi
  local FILE=$1
  if [[ -e $FILE ]]
  then
    mv -v --backup=numbered --no-target-directory $FILE $FILE.bak
  fi
}

report_conda()
# Assumes LABEL is a global
{
  if ! which python
  then
    echo "$LABEL: no python in PATH!"
    return 1
  fi
  if [[ ${CONDA_PREFIX:-0} == 0 ]]
  then
    echo "$LABEL: no CONDA_PREFIX: set up Anaconda"
    return 1
  fi
  echo "$LABEL: python:      " $( which python )
  echo "$LABEL: CONDA_PREFIX:" ${CONDA_PREFIX}
}
