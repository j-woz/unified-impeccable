
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
