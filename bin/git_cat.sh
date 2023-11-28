#!/bin/bash

#set -x
set -e

p1=$1;
p2=$2;
p3=$3;

if [[ "$p1" == "" ]]; then
  echo "ERROR: options missing - check parameters git cat {<rev>} <file>";
  exit -1;
elif [[ "$p2" == "" ]]; then
  root_dir=`git root`
  p1r=`realpath --relative-to=$root_dir $p1`
  cd $root_dir
  git show HEAD:$p1r;
elif [[ "$p3" != "" ]]; then
  echo "ERROR: too many options - check parameters git cat {<rev>} <file>";
  exit -1;
else
  # following is not always working properly in combination with relative back paths: e.g. git cat ../file
  #git show $p1:$p2;
  root_dir=`git root`
  p2r=`realpath --relative-to=$root_dir $p2`
  cd $root_dir
  git show $p1:$p2r;
  # git cat-file blob $p1:$p2r;
fi

