#!/bin/bash
set -eu

main()
{
  for STEP in {1,2,3,4,5,6}
  do
    if ! DB_check $STEP
    then
      run_step $STEP
    fi
  done
}

run_step()
{
  STEP=$1
  step$STEP/wf-step.sh
}

main
