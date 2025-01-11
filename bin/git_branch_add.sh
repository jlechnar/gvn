#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

if [[ "$#" == "1" ]]; then
  branch_name=$1
  commit_ish=""
elif [[ "$#" == "2" ]]; then
  branch_name=$1
  commit_ish=$2
else
  echo "ERROR: Unexpected number of parameters, expected is {<branch_to_delete>}"
  exit -1
fi

dot_git_path_abs=`$GIT get-dot-git-path-abs`
branch_current=`$GIT branch --show-current`

if [[ $is_gvn ]]; then
  if ! [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git branch-add / git ba instead. Aborting.";
    exit -1
  fi

  branch_exists=`$GIT check-branch-exists $branch_name`
  if [[ "$branch_exists" == "1" ]]; then
    echo "ERROR: branch with name $branch_name already exists. Aborting creation of new branch."
    exit -1
  fi

  if [ -f $dot_git_path_abs/gvn/branch/$branch_name ]; then
    echo "ERROR: branch with name $branch_name already exists. Aborting creation of new branch."
    exit -1
  fi

  if [[ "$commit_ish" != "" ]]; then
    echo "ERROR: add branch per commit not yet supported"
    exit -1
  #else
  fi
else
  if [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git-svn folder. Use gvn branch-add / gvn ba instead. Aborting.";
    exit -1
  fi
fi

$GIT branch $branch_name $commit_ish

if [[ $is_gvn ]]; then
  echo "$branch_name $branch_current" > $dot_git_path_abs/gvn/branch/$branch_name
fi
