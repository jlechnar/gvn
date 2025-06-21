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

worktree_or_branch_name=$1
dot_git_path_abs=`$GIT get-dot-git-path-abs`

if [[ $is_gvn ]]; then
  if ! [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git worktree-delete / git wd instead. Aborting.";
    exit -1
  fi
else
  if [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git-svn folder. Use gvn worktree-delete / gvn wd instead. Aborting.";
    exit -1
  fi
fi

is_branch_name=`$GIT worktree-get-branch $worktree_or_branch_name || true`
worktree_of_branch_exists=`$GIT worktree list | egrep "\[$worktree_or_branch_name\]$" || true`

if [[ $is_branch_name ]]; then
  branch_name=$is_branch_name
elif [[ $worktree_of_branch_exists ]]; then
  branch_name=$worktree_or_branch_name
else
  echo "ERROR: Could not detect branch/worktree for $worktree_or_branch_name. Aborting delete operation."
  exit -1
fi

worktree_path=`$GIT worktree list -v | grep " \[$branch_name\]" | awk '{print $1}'`

$GIT worktree remove $worktree_path

# cleanup gvn branch info
if [[ $is_gvn ]]; then
  if [ -f $dot_git_path_abs/gvn/branch/$branch_name ]; then
    rm -rf $dot_git_path_abs/gvn/branch/$branch_name
  fi
fi

