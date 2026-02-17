#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# usage: gvn wm <worktree_branch>
# merges back changes from a worktree branch that base upon the current branch which is a git svn branch and so a real svn branch

if [[ -n "${GVN_CONFIG_SH_OVERRIDE}" ]]; then
  source $GVN_CONFIG_SH_OVERRIDE
else
  SCRIPT_DIR_REAL=`realpath $0`
  SCRIPT_DIR=`dirname $SCRIPT_DIR_REAL`
  source $SCRIPT_DIR/config.sh
fi

set -e

branch_to_merge_to=$1

root=`$GIT root`
export GIT_WORK_TREE=$root

$GVN check-branch-to-be-svn-branch
$GVN check-for-branch-name-match

if [ `$GIT rev-parse --verify $branch_to_merge_to 2>/dev/null` ]; then
  branch_to_merge=`$GIT rev-parse --abbrev-ref HEAD`

  head_branch_to_merge=`$GIT rev-parse HEAD`
  head_branch_to_merge_to=`$GIT rev-parse $branch_to_merge_to`

  head_branch_to_merge_short=`echo $head_branch_to_merge | cut -c 1-$GVN_ALL__WIDTH_ABBREVIATED_HASH`
  head_branch_to_merge_to_short=`echo $head_branch_to_merge_to | cut -c 1-$GVN_ALL__WIDTH_ABBREVIATED_HASH`

  if [[ "$head_branch_to_merge" != "$head_branch_to_merge_to" ]]; then
    datetime=`date +'%Y%m%d_%H%M%S'`
    tagname="auto_${datetime}_gvn_worktree_merge_${branch_to_merge}_into_${branch_to_merge_to}"
    $GIT tag -a $tagname -m "auto generated git merge tag $datetime (git ${branch_to_merge} ${head_branch_to_merge} into ${branch_to_merge_to} ${head_branch_to_merge_to})"
    echo "Created Tag for $GIT merge: $tagname"
  fi
  $GIT merge --ff-only $@
else
  $GIT merge $@
fi
