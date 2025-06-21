#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

if [[ "$#" == "1" ]]; then
  worktree_prefix="$1"
  $GIT config gvn.worktree.prefix $worktree_prefix
  echo "WORKTREE_PREFIX set to: $worktree_prefix"
else
  worktree_prefix=`$GIT config gvn.worktree.prefix || true`
  echo "WORKTREE_PREFIX: $worktree_prefix"
fi


