#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

branch_name=$1
branch_path_name=$2

dot_git_path_abs=`$GIT get-dot-git-path-abs`

c1grep() { grep "$@" || test $? = 1; }
c1egrep() { egrep "$@" || test $? = 1; }

if [[ -z $branch_path_name ]]; then
  branch_name_tmp="${branch_name}_branch"
else
  branch_name_tmp=$branch_path_name
fi

remote_branch=`$GIT branch -a --no-color | egrep "/${branch_name}\$" | grep 'remotes/' | sed -e 's,^\s*remotes/,,g'`
if [[ $remote_branch == "" ]]; then
  echo "ERROR: Could not find matching remote branch for branch named <$branch_name>. Aborting.";
  exit -1
fi

local_branch_exists=`$GIT branch --no-color -a | $GIT awk-1 | c1egrep "^${branch_name}\$"`
if [[ $local_branch_exists != "" ]]; then
  echo "ERROR: Local branch ${local_branch_exists} exists. Aborting."
  exit -1
fi

remote_branch_tmp_exists=`$GIT branch --no-color -a | $GIT awk-1 | c1egrep "/${branch_name_tmp}\$"`
if [[ $remote_branch_tmp_exists != "" ]]; then
  echo "ERROR: Remote branch ${remote_branch_tmp_exists} exists. Aborting."
  exit -1
fi

local_branch_tmp_exists=`$GIT branch --no-color -a | $GIT awk-1 | c1egrep "^${branch_name_tmp}\$"`
if [[ $local_branch_tmp_exists != "" ]]; then
  echo "ERROR: Local branch ${local_branch_tmp_exists} exists. Aborting."
  exit -1
fi

# gvn wa "$branch_name_tmp"
export IGNORE_GVN_REPO=1
$GIT wa "$branch_name_tmp"

worktree_path=`$GIT wl | grep "\[${branch_name_tmp}\]" | $GIT awk1`
cd $worktree_path

$GIT checkout -b $branch_name "$remote_branch"

# remove temporary branch
$GIT branch -D $branch_name_tmp
