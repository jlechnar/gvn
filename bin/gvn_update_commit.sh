#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

usage() { # echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1;
  echo "FIXME"
  exit -1
}

do_stash=0

while getopts "sc" o; do
    case "${o}" in
        s)
            do_stash=1
            ;;
        c)
            do_commit=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


root=`git root`
export GIT_WORK_TREE=$root

gvn check-for-branch-name-match

if [[ $do_stash ]]; then
  changes=`git stash-local-changes-if-any`; \
else
  git check-for-unexpected-local-changes
fi

gvn fetch
gvn rebase

if [[ $do_commit ]]; then
  gvn commit
fi

if [[ $do_stash ]]; then
  if [[ "$changes" != "" ]]; then
    git stash pop
  fi
fi

