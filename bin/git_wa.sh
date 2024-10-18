#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# usage: git wa <worktree_branch_name>
# usage: git wa <worktree_branch_name> -b <branchname>
# usage: git wa <worktree_branch_name> <other_options>

set -e
# set -x

worktree_name=$1
shift
parameters=$@

dot_git_path_abs=`git get-dot-git-path-abs`

if [[ ! -z "$IGNORE_GVN_REPO" ]]; then
  true
elif [[ -e $dot_git_path_abs/svn/.metadata ]]; then
  echo "ERROR: Detected repository to be a git-svn folder. Use gvn worktree-add / gvn wa instead. Aborting.";
  exit -1
fi

main_path=`git rev-parse --path-format=absolute --show-toplevel`

cd $main_path
cd ..
cwd=`pwd`
cd $main_path

path="$cwd/$worktree_name"
git worktree add $path $parameters
