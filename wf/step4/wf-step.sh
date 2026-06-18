#!/bin/bash
set -eu

if DB
then
  ./sub_p2_s4a.sh ...
  DB insert
fi

if DB
then
  DB insert
  ./sub_p2_s4b.sh ...
fi

./sub_p2_s4c.sh ...
./sub_p2_s4d.sh ...

