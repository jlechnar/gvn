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
  worktree_postfix="$1"
  $GIT config gvn.worktree.postfix $worktree_postfix
  echo "WORKTREE_POSTIX set to: $worktree_postfix"
else
  worktree_postfix=`$GIT config gvn.worktree.postfix || true`
  echo "WORKTREE_POSTFIX: $worktree_postfix"
fi


