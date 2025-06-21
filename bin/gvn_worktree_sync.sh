#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# usage: gvn ws // if on worktree branch not connected to svn (created before with gvn wa <branchname>
#        gvn ws <branchname> // if on main branch connected to svn
# automatically detects base branch
# if branches are related each other it automatically selects and runs gvn worktree-rebase or worktree-merge.

set -e
# set -x

branch_to_sync=$1

$GVN check-branch-to-be-svn-branch

root=`$GIT root`

branch_current=`$GIT branch --show-current`
branch_current_svn=`$GVN currentbranch`
dot_git_path=`$GIT get-dot-git-path-abs`

if [ -z $branch_to_sync ]; then
  if [ -f $dot_git_path/gvn/branch/$branch_current ]; then
    branch_to_sync=`cat $dot_git_path/gvn/branch/$branch_current | $GIT awk2`
    echo "INFO: Auto-detected branch to sync to be <$branch_to_sync>."
  else
    possible_branches=`cat $dot_git_path/gvn/branch/* | grep "$branch_current\$" | $GIT awk1 | sed "s,^, ,g"`
    if [[ "$possible_branches" == "" ]]; then
      echo "ERROR: Could not detect any branch to sync. No worktree/branch available related to $branch_current."
      exit -1
    else
      echo "ERROR: Master worktree detected / Could not detect base to sync. Candidates are:"
      echo "$possible_branches"
      exit -1
    fi
  fi
fi

if [[ "$branch_to_sync" == "$branch_current" ]]; then
  echo "ERROR: Cannot sync branch to same branch <$branch_to_sync> == <$branch_current>."
  exit -1
fi

if [[ "$branch_current" == "$branch_current_svn" ]]; then

  echo "INFO: try to sync via merge <$branch_to_sync> into <$branch_current> for svn base <$branch_current_svn>."
  if [ -f $dot_git_path/gvn/branch/$branch_current ]; then
    echo "ERROR: Found unexpected branch information file <$dot_git_path/gvn/branch/$branch_current>. Must not exist for none worktree / main branches that are bound to real svn repos. Aborting sync (merge) operation."
    exit -1
  fi
  if [ -f $dot_git_path/gvn/branch/$branch_to_sync ]; then
    branch_to_sync_svn_from_file=`cat $dot_git_path/gvn/branch/$branch_to_sync | $GIT awk2`
    if [[ "$branch_to_sync_svn_from_file" != "$branch_current_svn" ]]; then
      echo "ERROR: Detected missmatch in svn base branch <$branch_to_sync_svn_from_file> (<$branch_to_sync>) != <$branch_current_svn> ($branch_current). Aborted sync (merge) of <$branch_to_sync> into <$branch_current>."
      exit -1
    fi
    echo "INFO: detected current branch <$branch_current> to be base for branch to sync <$branch_to_sync>."
    echo "INFO: merging branch to sync <$branch_to_sync> into current branch <$branch_current>."
    export GIT_WORK_TREE=$root
    changes=`$GIT stash-local-changes-if-any`
    $GVN worktree-merge $branch_to_sync
    if [[ "$changes" != "" ]]; then
      $GIT stash pop
    fi
  else
    echo "ERROR: Could not find branch information file <$dot_git_path/gvn/branch/$branch_to_sync>. Aborting sync (merge) operation."
    exit -1
  fi

elif [[ "$branch_to_sync" == "$branch_current_svn" ]]; then

  echo "INFO: try to sync via rebase <$branch_current> onto <$branch_to_sync> for svn base <$branch_current_svn>."
  if [[ -f $dot_git_path/gvn/branch/$branch_to_sync ]]; then
    echo "ERROR: Found unexpected branch information file <$dot_git_path/gvn/branch/$branch_to_sync>. Must not exist for none worktree / main branches that are bound to real svn repos. Aborting sync (rebase) operation."
    exit -1
  fi
  if [[ -f $dot_git_path/gvn/branch/$branch_current ]]; then
    branch_current_svn_from_file=`cat $dot_git_path/gvn/branch/$branch_current | $GIT awk2`
    if [[ "$branch_current_svn_from_file" != "$branch_current_svn" ]]; then
      echo "ERROR: Detected missmatch in svn base branch <$branch_current_svn_from_file> (<$branch_to_sync>) != <$branch_current_svn> ($branch_current). Aborted sync (rebase) of <$branch_current> onto <$branch_to_sync>."
      exit -1
    fi
    echo "INFO: detected current branch <$branch_current> to base upon branch to sync <$branch_to_sync>."
    echo "INFO: rebasing current branch <$branch_current> onto branch to sync <$branch_to_sync>."
    export GIT_WORK_TREE=$root
    changes=`$GIT stash-local-changes-if-any`
    $GVN worktree-rebase $branch_to_sync
    if [[ "$changes" != "" ]]; then
      $GIT stash pop
    fi
  else
    echo "ERROR: Could not find branch information file <$dot_git_path/gvn/branch/$branch_current>. Aborting sync (rebase) operation."
    exit -1
  fi

else

  echo "ERROR: Could not detect valid sync branches for current <$branch_current> to <$branch_to_sync>. Aborting sync operation."
  exit -1
fi
