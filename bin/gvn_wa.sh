#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


# usage: gvn wa <worktree_branch_name>
# Adds a worktree with <worktree_branch_name> parallel to the root folder of the current git sandbox.
# The name of the folder is "<worktree_branch_name>",
# Worktrees are special in case of git svn => for synching (automatic merging/rebasing) we need to know the base of the worktree, this is the name of the svn branch base!
# We only allow one parameter no <commit-ish> parameter selection, hence it is always forked of the current branch which must be a real svn branch !
# Note that base information is required and stored in .git/gvn/branch/<worktree/branch> files as "<worktree> <base svn branch of worktree>".
# Worktrees can only be created on branch that is related to real svn branch (name match of branch and svn repo branch) !

set -e

worktree_name=$1

gvn check-branch-to-be-svn-branch
gvn check-for-branch-name-match

branch_current=`git branch --show-current`
dot_git_path_abs=`git get-dot-git-path-abs`

mkdir -p $dot_git_path_abs/gvn/branch/

if [ -f $dot_git_path_abs/gvn/branch/$worktree_name ]; then
  echo "ERROR: worktree/branch with name $worktree_name already exists. Aborting creation of new worktree/branch."
  exit -1
fi

main_path=`git rev-parse --path-format=absolute --show-toplevel`
cd $main_path
cd ..
cwd=`pwd`
cd $main_path

path="$cwd/$worktree_name"
git worktree add $path -b $worktree_name

echo "$worktree_name $branch_current" > $dot_git_path_abs/gvn/branch/$worktree_name
