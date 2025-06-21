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

root=`$GIT root`
export GIT_WORK_TREE=$root

$GVN check-branch-to-be-svn-branch
$GVN check-for-branch-name-missmatch

if [ `$GIT rev-parse --verify $branch_to_rebase_to 2>/dev/null` ]; then
  branch_to_rebase=`$GIT rev-parse --abbrev-ref HEAD`
  head_branch_to_rebase=`$GIT rev-parse HEAD`
  head_branch_to_rebase_to=`$GIT rev-parse $branch_to_rebase_to`
  if [[ "$head_branch_to_rebase" != "$head_branch_to_rebase_to" ]]; then
    datetime=`date +'%Y_%m_%d-%H_%M_%S'`
    $GIT tag -a gvn_worktree_rebase_${datetime}_${branch_to_rebase}_${head_branch_to_rebase}_to_${branch_to_rebase_to}_${head_branch_to_rebase_to} -m "$GIT rebase tag $datetime ($GIT ${branch_to_rebase} ${head_branch_to_rebase} to ${branch_to_rebase_to} ${head_branch_to_rebase_to})"
    echo "Created Tag for $GIT rebase: gvn_worktree_rebase_${datetime}_${branch_to_rebase}_${head_branch_to_rebase}_to_${branch_to_rebase_to}_${head_branch_to_rebase_to}"
    $GIT rebase-notag $@
  else
    $GIT rebase $@
  fi
else
  $GIT rebase $@
fi
