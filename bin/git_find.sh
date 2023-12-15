#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

rt=`git root`

tree="HEAD"

current_dir=`pwd`
root_dir=`git root`

if [[ "$#" == "0" ]]; then
  search="*"
  path=$root_dir
elif [[ "$#" == "1" ]]; then
  search="$1"
  path=$root_dir
elif [[ "$#" == "2" ]]; then
  search="$1"
  path="$2"
else
  echo "ERROR: options missing - check parameters git find <file_name> <folder> OR git find <file_name> to search in current folder recursively"; \
  exit -1; \
fi

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

IFS=$'\n'

cmd="git ls-tree --name-only -r $tree"
for result in `eval $cmd`;
do
  result2=`echo $result | sed "s,^,$root_dir/,g" | grep "^$target_dir/" | sed "s,^$target_dir/,$relative_to_reduced,g" | grep -v "^$target_dir$" | egrep "$search"` || true
  if [[ "$result2" != "" ]]; then
    echo $result2
    #realpath --relative-to=$path $result2 | echo
  fi
done

