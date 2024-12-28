#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

#git diff --follow $@ | xargs -I '{}' realpath --relative-to=. $(git rev-parse --show-toplevel)/'{}'

usage() { echo "Usage: $0 <-l: local> <-r: remote> <branch_to_delete> {<remote>}" 1>&2; exit 1; }

delete_local=0
delete_remote=0

while getopts "lr" o; do
    case "${o}" in
        l)
            delete_local=1
            ;;
        r)
            delete_remote=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# FIXME: allow only single parameter in case of delete all ?
if [[ "$delete_remote" == "0" ]]; then
  if [[ "$#" == "1" ]]; then
    branch_name=$1;
  else
    echo "ERROR: Unexpected number of parameters, expected is {<branch_to_delete>}";
    exit -1;
  fi
else
  if [[ "$#" == "2" ]]; then
    branch_name=$1
    remote_name=$2
  else
    echo "ERROR: Unexpected number of parameters, expected is {<branch_to_delete> <remote>}"
    exit -1
  fi
fi

dot_git_path_abs=`git get-dot-git-path-abs`

if [[ $is_gvn ]]; then
  if ! [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git branch-delete / git bd instead. Aborting.";
    exit -1
  fi
else
  if [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git-svn folder. Use gvn branch-delete / gvn bd instead. Aborting.";
    exit -1
  fi
fi

if [[ "$delete_local" == "1" ]]; then
  git branch -d $branch_name

  if [[ $is_gvn ]]; then
    rm -rf $dot_git_path_abs/gvn/branch/$branch_name
  fi
fi

if [[ "$delete_remote" == "1" ]]; then
  git push -d $remote_name $branch_name
fi

