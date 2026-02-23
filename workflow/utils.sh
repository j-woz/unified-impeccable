
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

bac()
# Copy given file to numbered backup
# If file does not exist, nothing to backup, no problem.
{
  if (( ${#} != 1 ))
  then
    echo "bac(): provide FILE!"
    return 1
  fi
  if [[ -e $FILE ]]
  then
    cp -v --backup=numbered --no-target-directory $FILE $FILE.bac
  fi
}

assert-exists()
# Test for file/directory existence
# Intersperse file names with -v for verbose, +v for silent (default)
# or test flags -e/-f/-d etc. (default -e)
{
  local MODE="-e" t
  local VERBOSE=0
  for t in ${*}
  do
    case $t in
      -v) VERBOSE=1
          continue ;;
      +v) VERBOSE=0
          continue ;;
      -*) MODE=${t}
          continue ;;
    esac
    if (( VERBOSE ))
    then
      echo test $MODE $t
    fi
    if ! test $MODE $t
    then
      msg "assert-exists: FAIL: [test $MODE] $t"
      msg "assert-exists: PWD: " $( pwd -P )
      return 1
    fi
  done
}

show()
# Report variable names with their values
# Assumes LABEL is a global
{
  for v in $*
  do
    eval "msg $v=\${$v:-}"
  done
}

msg()
# MeSsaGe
{
  echo $( date "+%Y-%m-%d %H:%M:%S" ) ${LABEL:-}: ${*}
}

msgf()
# MeSsaGe - Formatted
{
  local T
  printf -v T ${*}
  msg ${T}
}

fail()
{
  msg ${*}
  return 1
}

function @ ()
# Verbose command execution
# Like set -x or output from Makefile
{
  msg ${*}
  if ${*}
  then
    : OK
  else
    CODE=${?}
    echo
    msg "@ COMMAND ERROR: CODE=$CODE"
    return $CODE
  fi
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
    msg "no python in PATH!"
    return 1
  fi
  if [[ ${CONDA_PREFIX:-0} == 0 ]]
  then
    msg "no CONDA_PREFIX: set up Anaconda"
    return 1
  fi
  msg      "python:     "   $( which python )
  show     CONDA_PREFIX PYTHONUSERBASE
  log-path PYTHONPATH
}

tm()
# Assumes LABEL is a global
{
  /usr/bin/time --format="$LABEL: TIME: %E" ${*}
}

namd-catch()
# Catches spurious NAMD shutdown-time error
{
  if [[ ${NAMD:-} == "" ]] || (( ${#} != 2 ))
  then
    echo "namd-catch(): Set NAMD, provide CFG and LOG!"
    return 1
  fi
  local CFG=$1
  local LOG=$2

  # Start with fresh log:
  bak $LOG

  # Run NAMD!
  if @ $NAMD --tclmain $CFG +stdout $LOG
  then
    msg "NAMD success."
  else
    # Allow crashes if log indicates success:
    if grep -q "End of program" $LOG
    then
      msg "NAMD success after error."
    else
      msg "NAMD ERROR: log is not complete!"
      msg "NAMD ERROR: LOG: $LOG"
      exit 1
    fi
  fi
}

namd-margin-0()
# Insert "margin 0.0" for CUDA stability : from Wei Jiang (ALCF)
{
  if (( ${#} != 1 ))
  then
    echo "namd-margin-0(): Provide CFG!"
    return 1
  fi
  local CFG=$1
  if ! grep -q "margin 0.0" $CFG
  then
    sed -i "/run/imargin 0.0" $CFG
  fi
}
