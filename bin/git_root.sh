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

git_dir=`$GIT rev-parse --git-dir`
git_dir=`realpath $git_dir`

git_dir2=$git_dir
if [[ -e $git_dir/gitdir ]]; then
  git_dir2=`cat $git_dir/gitdir`
fi

root_dir1=`echo $git_dir2 | sed 's,.git$,,g'`

cdup_dir=`$GIT rev-parse --show-cdup`
if [[ ! $cdup_dir ]]; then
  cdup_dir="."
fi
root_dir2=`realpath $cdup_dir`

if [[ $git_dir =~ /.git/worktrees/ ]]; then
  if [[ $git_dir =~ /.git/worktrees/.*/modules/ ]]; then
    if [[ "$GVN_DEBUG" == "1" ]]; then
      echo "WORKTREE MODULE" >&2
    fi
    root_dir="$root_dir2"
  else
    if [[ "$GVN_DEBUG" == "1" ]]; then
      echo "WORKTREE" >&2
    fi
    root_dir="$root_dir1"
  fi
else
  if [[ $git_dir =~ /.git/modules/ ]]; then
    if [[ "$GVN_DEBUG" == "1" ]]; then
      echo "BASE MODULE" >&2
    fi
    root_dir="$root_dir2"
  else
    if [[ "$GVN_DEBUG" == "1" ]]; then
      echo "BASE" >&2
    fi
    root_dir="$root_dir1"
  fi
fi

root_dir=`echo $root_dir | sed 's,/$,,g'`

# in case of git_overlay overlays we always get .git_overlay as extension to the root path and so path compares fail
# remove them to solve the issue
root_dir=`echo $root_dir | sed 's,/.git_overlay$,,g'`

echo $root_dir

