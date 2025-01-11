#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

usage() {
  echo "FIXME"
  exit -1
}

list_local=0
list_remote=0
list_all=0

while getopts "lraR" o; do
    case "${o}" in
        l)
            list_local=1
            ;;
        R)
            list_remote=1
            list_remote_all=1
            ;;
        r)
            list_remote=1
            ;;
        a)
            list_remote_all=1
            list_local=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

args_nr=$#
args=$@

add_newline=0

if [[ $list_local ]]; then
  git tag
  local_tags=`git tag`
  if [[ ! "$local_tags" == "" ]]; then
    # echo "$local_tags"
    add_newline=1
  fi
fi

skip_remote_all=0
if [[ "$list_remote" == "1" ]]; then
  if [[ "$args_nr" == "1" ]]; then
    remote_tags=`git ls-remote --tags $args`

    if [[ "$add_newline" == "1" && ! "$remote_tags" == "" ]]; then
      echo ""
    fi

    git ls-remote --tags $args
    skip_remote_all=1
  fi
fi

if [[ "$skip_remote_all" == "0" ]]; then
  if [[ "$list_remote_all" == "1" ]]; then
    for remote in `git remote`; do
      if [[ "$add_newline" == "1" ]]; then
        echo ""
      fi
      echo "Remote: $remote"
      git ls-remote --tags $remote
      remote_tags=`git ls-remote --tags $remote`
      if [[ ! "$remote_tags" == "" ]]; then
        # echo "$remote_tags"
        add_newline=1
      fi
    done
  fi
fi

