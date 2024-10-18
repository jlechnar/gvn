#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

branch_name=$1
branch_path_name=$2

dot_git_path_abs=`git get-dot-git-path-abs`

c1grep() { grep "$@" || test $? = 1; }
c1egrep() { egrep "$@" || test $? = 1; }

if [[ -z $branch_path_name ]]; then
  branch_name_tmp="${branch_name}_branch"
else
  branch_name_tmp=$branch_path_name
fi

remote_branch=`git branch -a --no-color | egrep "/${branch_name}\$" | grep 'remotes/' | sed -e 's,^\s*remotes/,,g'`
if [[ $remote_branch == "" ]]; then
  echo "ERROR: Could not find matching remote branch for branch named <$branch_name>. Aborting.";
  exit -1
fi

local_branch_exists=`git branch --no-color -a | git awk-1 | c1egrep "^${branch_name}\$"`
if [[ $local_branch_exists != "" ]]; then
  echo "ERROR: Local branch ${local_branch_exists} exists. Aborting."
  exit -1
fi

remote_branch_tmp_exists=`git branch --no-color -a | git awk-1 | c1egrep "/${branch_name_tmp}\$"`
if [[ $remote_branch_tmp_exists != "" ]]; then
  echo "ERROR: Remote branch ${remote_branch_tmp_exists} exists. Aborting."
  exit -1
fi

local_branch_tmp_exists=`git branch --no-color -a | git awk-1 | c1egrep "^${branch_name_tmp}\$"`
if [[ $local_branch_tmp_exists != "" ]]; then
  echo "ERROR: Local branch ${local_branch_tmp_exists} exists. Aborting."
  exit -1
fi

# gvn wa "$branch_name_tmp"
export IGNORE_GVN_REPO=1
git wa "$branch_name_tmp"

worktree_path=`git wl | grep "\[${branch_name_tmp}\]" | git awk1`
cd $worktree_path

git checkout -b $branch_name "$remote_branch"

# remove temporary branch
git branch -D $branch_name_tmp
