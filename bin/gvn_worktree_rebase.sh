#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# usage: gvn wr <worktree_base_branch>
# rebases all local changes after updating to the changes from the worktree_base_branch which is a git svn branch and so a real svn branch
# Working branch must not be a real svn branch but a worktree branch of a real one.

if [[ -n "${GVN_CONFIG_SH_OVERRIDE}" ]]; then
  source $GVN_CONFIG_SH_OVERRIDE
else
  SCRIPT_DIR_REAL=`realpath $0`
  SCRIPT_DIR=`dirname $SCRIPT_DIR_REAL`
  source $SCRIPT_DIR/config.sh
fi

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

  head_branch_to_rebase_short=`echo $head_branch_to_rebase | cut -c 1-$GVN_ALL__WIDTH_ABBREVIATED_HASH`
  head_branch_to_rebase_to_short=`echo $head_branch_to_rebase_to | cut -c 1-$GVN_ALL__WIDTH_ABBREVIATED_HASH`

  if [[ "$head_branch_to_rebase" != "$head_branch_to_rebase_to" ]]; then
    datetime=`date +'%Y%m%d_%H%M%S'`
    tagname="auto_${datetime}_gvn_worktree_rebase_${branch_to_rebase}_onto_${branch_to_rebase_to}"
    $GIT tag -a $tagname -m "auto generated git rebase tag $datetime (git ${branch_to_rebase} ${head_branch_to_rebase} onto ${branch_to_rebase_to} ${head_branch_to_rebase_to})"
    echo "Created Tag for $GIT rebase: $tagname"
    $GIT rebase-notag $@
  else
    $GIT rebase $@
  fi
else
  $GIT rebase $@
fi
