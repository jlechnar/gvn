#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

p1=$1;
p2=$2;

if [[ "$#" == "1" ]]; then
  is_branch=`$GIT branch -a --no-color -l --format "%(refname:short)"| grep "^$p1$"` || true;
  if [[ "$is_branch" == "" ]]; then
    tree="HEAD";
    path=$p1;
  else
    tree=$p1;
    path="";
  fi;
elif [[ "$#" == "2" ]]; then
  tree=$p1;
  path=$p2;
elif [[ "$#" == "0" ]]; then
  tree="HEAD";
  path="";
else
  echo "ERROR: options missing - check parameters: git lsa OR git lsa <rev>/<folder> OR git lsa <rev/branch> <folder>";
  exit -1;
fi

current_dir=`pwd`
root_dir=`$GIT root`

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

cmd="$GIT ls-tree --name-only -r $tree"
for result in `eval $cmd`;
do
  result2=`echo $result | sed "s,^,$root_dir/,g" | grep "^$target_dir/" | sed "s,^$target_dir/,$relative_to_reduced,g" | grep -v "^$target_dir$"` || true
  if [[ "$result2" != "" ]]; then
    echo $result2
  fi
done

