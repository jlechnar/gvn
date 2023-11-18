#!/bin/bash

set -e
set -x

file=$1

cat $file | \
  sed '/An error was found, but returning just with the version: Blessed needs Python/d' | \
  perl -pe 's/\e\[0m/\e\[m/g'
# | \
#  sed -e 's,^[[0m,^[m,g'

