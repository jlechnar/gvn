#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# worktree delete

set -e

worktree_name=$1
branch_current=`git branch --show-current`
dot_git_path_abs=`git get-dot-git-path-abs`

if [ ! -f $dot_git_path_abs/gvn/branch/$worktree_name ]; then
  echo "ERROR: worktree/branch with name $worktree_name does not exist. Aborting delete operation."
  exit -1
fi

git worktree remove $worktree_name

rm -rf $dot_git_path_abs/gvn/branch/$worktree_name

