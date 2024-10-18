#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# usage: gvn wm <worktree_branch>
# merges back changes from a worktree branch that base upon the current branch which is a git svn branch and so a real svn branch

set -e

branch_to_merge_to=$1

gvn check-branch-to-be-svn-branch
gvn check-for-branch-name-match

if [ `git rev-parse --verify $branch_to_merge_to 2>/dev/null` ]; then
  branch_to_merge=`git rev-parse --abbrev-ref HEAD`
  head_branch_to_merge=`git rev-parse HEAD`
  head_branch_to_merge_to=`git rev-parse $branch_to_merge_to`
  if [[ "$head_branch_to_merge" != "$head_branch_to_merge_to" ]]; then
    datetime=`date +'%Y_%m_%d-%H_%M_%S'`
    git tag -a gvn_worktree_merge_${datetime}_${branch_to_merge}_${head_branch_to_merge}_to_${branch_to_merge_to}_${head_branch_to_merge_to} -m "git merge tag $datetime (git ${branch_to_merge} ${head_branch_to_merge} to ${branch_to_merge_to} ${head_branch_to_merge_to})"
    echo "Created Tag for git merge: gvn_worktree_merge_${datetime}_${branch_to_merge}_${head_branch_to_merge}_to_${branch_to_merge_to}_${head_branch_to_merge_to}"
  fi
  git merge --ff-only $@
else
  git merge $@
fi
