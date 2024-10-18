#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# usage: gvn wr <worktree_base_branch>
# rebases all local changes after updating to the changes from the worktree_base_branch which is a git svn branch and so a real svn branch
# Working branch must not be a real svn branch but a worktree branch of a real one.

set -e

branch_to_rebase_to=$1

gvn check-branch-to-be-svn-branch
gvn check-for-branch-name-missmatch

if [ `git rev-parse --verify $branch_to_rebase_to 2>/dev/null` ]; then
  branch_to_rebase=`git rev-parse --abbrev-ref HEAD`
  head_branch_to_rebase=`git rev-parse HEAD`
  head_branch_to_rebase_to=`git rev-parse $branch_to_rebase_to`
  if [[ "$head_branch_to_rebase" != "$head_branch_to_rebase_to" ]]; then
    datetime=`date +'%Y_%m_%d-%H_%M_%S'`
    git tag -a gvn_worktree_rebase_${datetime}_${branch_to_rebase}_${head_branch_to_rebase}_to_${branch_to_rebase_to}_${head_branch_to_rebase_to} -m "git rebase tag $datetime (git ${branch_to_rebase} ${head_branch_to_rebase} to ${branch_to_rebase_to} ${head_branch_to_rebase_to})"
    echo "Created Tag for git rebase: gvn_worktree_rebase_${datetime}_${branch_to_rebase}_${head_branch_to_rebase}_to_${branch_to_rebase_to}_${head_branch_to_rebase_to}"
  fi
  git rebase $@
else
  git rebase $@
fi
