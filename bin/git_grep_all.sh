#!/bin/bash

#set -x
set -e

args=$@

current_dir=`pwd`
root_dir=`git root`

path=$root_dir
tree="HEAD"

if [[ $path =~ ^/ ]]; then
  target_dir=`realpath $path`
else
  target_dir=`realpath $current_dir/$path`
fi

relative_to=`realpath --relative-to=$current_dir $target_dir`
relative_to_reduced="$relative_to/"
if [[ "$relative_to" == "." ]]; then
  relative_to_reduced=""
fi

cd $root_dir

results=`git egrep $args | sed "s,^,$root_dir/,g" | grep "^$target_dir/" | sed "s,^$target_dir/,$relative_to_reduced,g"`

for result in $results;
do
  echo $result
done

