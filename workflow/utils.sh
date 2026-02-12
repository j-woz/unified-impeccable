
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

show()
# Report variable names with their values
# Assumes LABEL is a global
{
  for v in $*
  do
    eval "echo ${LABEL:-}: $v=\${$v:-}"
  done
}

log-path()
# Pretty print a colon-separated variable, one entry per line
# Provide the name of the variable (no dollar sign)
# Assumes LABEL is a global
{
  # First, test if $1 is the name of a set shell variable:
  if eval test \$\{$1:-\}
  then
    echo $LABEL: ${1}:
    eval echo \$$1 | tr : '\n' | nl
    echo --
    echo
  else
    echo "log-path(): ${1} is unset."
  fi
}

report-conda()
# Assumes LABEL is a global
{
  if ! which python 2>&1 > /dev/null
  then
    echo "$LABEL: no python in PATH!"
    return 1
  fi
  if [[ ${CONDA_PREFIX:-0} == 0 ]]
  then
    echo "$LABEL: no CONDA_PREFIX: set up Anaconda"
    return 1
  fi
  echo "$LABEL: python:     "   $( which python )
  show     CONDA_PREFIX PYTHONUSERBASE
  log-path PYTHONPATH
}
