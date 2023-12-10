#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

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

IFS=$'\n'

cmd="git egrep $args"
for result in `eval $cmd`;
do
  result2=`echo $result | sed "s,^,$root_dir/,g" | grep "^$target_dir/" | sed "s,^$target_dir/,$relative_to_reduced,g"` || true
  if [[ "$result2" != "" ]]; then
    echo $result2
  fi
done

