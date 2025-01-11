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

worktree_name=$1
dot_git_path_abs=`$GIT get-dot-git-path-abs`

if [[ $is_gvn ]]; then
  if ! [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git worktree-delete / git wd instead. Aborting.";
    exit -1
  fi

  branch_name=`$GIT worktree-get-branch $worktree_name || true`
  if ! [[ $branch_name ]]; then
    echo "ERROR: Could not detect branch for worktree $worktree_name. Aborting delete operation."
    exit -1
  fi

  if [ ! -f $dot_git_path_abs/gvn/branch/$branch_name ]; then
    echo "ERROR: worktree/branch with name $branch_name does not exist. Aborting delete operation."
    exit -1
  fi
else
  if [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git-svn folder. Use gvn worktree-delete / gvn wd instead. Aborting.";
    exit -1
  fi
fi

$GIT worktree remove $worktree_name

