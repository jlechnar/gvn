#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# worktree delete

set -e

branch_name=$1
dot_git_path_abs=`git get-dot-git-path-abs`

if [ -f $dot_git_path_abs/gvn/branch/$branch_name ]; then
  echo "ERROR: worktree/branch with name $branch_name exist as reference. Aborting delete operation."
  exit -1
fi

worktree_name2=`git worktree-branch-get-path $branch_name | sed 's,/, ,g' | git awk-1`

if [[ "$worktree_name2" == "" ]]; then
  echo "ERROR: worktree not found. Aborting delete operation."
  exit -1
fi

# FIXME: implement sanity check before removal of branch / worktree !

# git worktree remove --force $worktree_name2
# git branch -D $branch_name

git worktree remove $worktree_name2

git branch -d $branch_name
