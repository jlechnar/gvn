#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


# git
# usage: git wa <worktree_branch_name>
# usage: git wa <worktree_branch_name> <branchname/commit-ish>
# usage: git wa <worktree_branch_name> <branchname> <commit-ish>

# gvn
# usage: gvn wa <worktree_branch_name>
# usage: gvn wa <worktree_branch_name> <branchname/commit-ish>
# usage: gvn wa <worktree_branch_name> <branchname> <commit-ish>
# Adds a worktree with <worktree_branch_name> parallel to the root folder of the current git sandbox.
# The name of the folder is "<worktree_branch_name>",
# Worktrees are special in case of git svn => for synching (automatic merging/rebasing) we need to know the base of the worktree, this is the name of the svn branch base!
# We only allow one parameter no <commit-ish> parameter selection, hence it is always forked of the current branch which must be a real svn branch !
# Note that base information is required and stored in .git/gvn/branch/<worktree/branch> files as "<worktree> <base svn branch of worktree>".
# Worktrees can only be created on branch that is related to real svn branch (name match of branch and svn repo branch) !
#
# worktrees are placed in parallel to the main git work folder using the <worktree_branch_name>
# optionally the <worktree_branch_name> can be prefixed/postfixed using the configuration variables gvn.worktree.postfix and gvn.worktree.prefix
# Note that with this the worktree folder can also be placed in subfolders relative to the main git work folder

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

remote_branch=0
if [[ "$#" == "1" ]]; then
  worktree_name="$1"
  branch_name="$1"
  if [[ `$GIT check-branch-exists-remote $branch_name` == "1" ]]; then
    # checkout remote branch in worktree if exists
    # FIXME: is it a git-svn branch ?
    commit_ish="$branch_name"
    branch_name=`echo $branch_name | sed 's,/, ,g' | $GIT awk2`
    worktree_name="$branch_name"
    remote_branch=1
  fi
  # else start with head as base for new branch in worktree
 elif [[ "$#" == "2" ]]; then
  worktree_name="$1"
  branch_name="$2"
  commit_ish=""
  if [[ `$GIT check-branch-exists $branch_name` == "0" ]]; then
    # create new branch with same name as worktree_name from commit_ish if branch does not exist already
    branch_name="$worktree_name"
    commit_ish="$2"
  elif [[ `$GIT check-branch-exists-remote $branch_name` == "1" ]]; then
    # checkout remote branch in worktree if exists
    commit_ish="$branch_name"
    branch_name=`echo $branch_name | sed 's,/, ,g' | $GIT awk2`
    remote_branch=1
  # elif commit-ish exists then create create new branch with same name as worktree_name from commit_ish ?
  fi
  # else default create worktree with new branch name from current commit
elif [[ "$#" == "3" ]]; then
  # create branch in worktree from commit_ish
  branch_name="$1"
  worktree_name="$2"
  commit_ish="$3"
else
  if [[ $is_gvn ]]; then
    echo "ERROR: options missing - check parameters gvn wa <worktree_name> OR gvn wa <worktree_name> <commit-ish> OR gvn wa <worktree_name> <branch_name> <commit-ish> to add a new or existing branch to a new worktree"
  else
    echo "ERROR: options missing - check parameters git wa <worktree_name> OR git wa <worktree_name> <commit-ish> OR git wa <worktree_name> <branch_name> <commit-ish> to add a new or existing branch to a new worktree"
  fi
  exit -1
fi

if [[ $is_gvn ]]; then
  # sanity checks that current branch is git svn branch
  $GVN check-branch-to-be-svn-branch
  $GVN check-for-branch-name-match
fi

worktree_prefix=`$GIT config gvn.worktree.prefix || true`
worktree_postfix=`$GIT config gvn.worktree.postfix || true`

main_path=`$GIT rev-parse --path-format=absolute --show-toplevel`
cd $main_path
cd ..
cwd=`pwd`
cd $main_path
path="$cwd/$worktree_prefix$worktree_name$worktree_postfix"

dot_git_path_abs=`$GIT get-dot-git-path-abs`

if [[ $is_gvn ]]; then
  if ! [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git worktree-add / git wa instead. Aborting.";
    exit -1
  fi

  branch_current=`$GIT branch --show-current`

  mkdir -p $dot_git_path_abs/gvn/branch/

  if [ -d $path ]; then
    echo "ERROR: folder $path for new worktree $worktree_name already exists. Aborting creation of new worktree/branch."
    exit -1
  fi

  mkdir -p $path

  worktree_of_branch_exists=`$GIT worktree list | egrep "\[$branch_name\]$" || true`
  if [[ $worktree_of_branch_exists ]]; then
    echo "ERROR: Branch $branch_name already checked out as worktree. Aborting creation of new worktree/branch."
    exit -1
  fi

  # if [ -f $dot_git_path_abs/gvn/branch/$branch_name ]; then
  #   echo "ERROR: worktree/branch with branch name $branch_name already exists. Aborting creation of new worktree/branch."
  #   exit -1
  # fi
else
  if [[ ! -z "$IGNORE_GVN_REPO" ]]; then
    true
  elif [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git worktree-add / git wa instead. Aborting.";
    exit -1
  fi

  if [ -d $path ]; then
    echo "ERROR: folder $path for new worktree $worktree_name already exists. Aborting creation of new worktree/branch."
    exit -1
  fi

  mkdir -p $path
fi


if [[ "$remote_branch" == "1" ]]; then
  $GIT worktree add $path -b $branch_name $commit_ish
elif [[ `$GIT check-branch-exists $branch_name` == "1" ]]; then
  $GIT worktree add $path $branch_name $commit_ish
else
  $GIT worktree add $path -b $branch_name $commit_ish
fi

if [[ $is_gvn ]]; then
  if [[ "$remote_branch" == "0" ]]; then
    if ! [ -f $dot_git_path_abs/gvn/branch/$branch_name ]; then
      echo "$branch_name $branch_current" > $dot_git_path_abs/gvn/branch/$branch_name
    fi
  fi
fi
