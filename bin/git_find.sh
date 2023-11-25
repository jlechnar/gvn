#!/bin/bash

#set -x
set -e

tree="HEAD"

if [[ "$#" == "0" ]]; then
  search="*"
  path=`git rev-parse --show-toplevel`
elif [[ "$#" == "1" ]]; then
  search="$1"
  path=`git rev-parse --show-toplevel`
elif [[ "$#" == "2" ]]; then
  search="$1"
  path="$2"
else
  echo "ERROR: options missing - check parameters git find <file_name> <folder> OR git find <file_name> to search in current folder recursively"; \
  exit -1; \
fi

current_dir=`pwd`
root_dir=`git rev-parse --show-toplevel`

if [[ $path =~ ^/ ]]; then
  target_dir=`realpath $path`
else
  target_dir=`realpath $current_dir/$path`
fi

if [[ ! $target_dir == $root_dir* ]]; then
  echo "ERROR: Target directory <$target_dir> is outside of git repository <$root_dir>. Aborting."; \
  exit -1
fi

relative_to=`realpath --relative-to=$current_dir $target_dir`
relative_to_reduced="$relative_to/"
if [[ "$relative_to" == "." ]]; then
  relative_to_reduced=""
fi

cd $root_dir

files=`git ls-tree --name-only -r $tree | sed "s,^,$root_dir/,g" | grep "^$target_dir/" | sed "s,^$target_dir/,$relative_to_reduced,g" | grep -v "^$target_dir$" | egrep "$search"`

for file in $files;
do
  echo $file
done

