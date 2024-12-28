#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

# root
# below does not always work properly in subfolders in worktrees hence replaced with below implementation
#root = "rev-parse --show-toplevel"
#root = "!bash -c 'cd -- \"${GIT_PREFIX:-.}\"; \
#         current_dir=`pwd | sed 's,/$,,g'`; \
#         prefix=`echo $GIT_PREFIX | sed 's,/$,,g'`; \
#         root_dir=`echo $current_dir | sed \"s,/$prefix$,,\" | xargs realpath`; \
#         echo $root_dir' --"
#root = "!bash -c 'cd -- \"${GIT_PREFIX:-.}\"; \
#         current_branch=`git currentbranch`; \
#         root_dir=`git worktree-branch-get-path $current_branch`; \
#         echo $root_dir' --"

current_branch=`git currentbranch`
root_dir=`git worktree-branch-get-path $current_branch`

# in case of git_overlay overlays we always get .git_overlay as extension to the root path and so path compares fail
# remove them to solve the issue
root_dir=`echo $root_dir | sed 's,/.git_overlay$,,g'`

echo $root_dir

