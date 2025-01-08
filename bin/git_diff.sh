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

opts=""

do_follow=0

while getopts "icNfw" o; do
    case "${o}" in
        i)
            opts="$opts --ignore-all-space --ignore-blank-lines --ignore-space-change"
            ;;
        c)
            opts="$opts --cached"
            ;;
        N)
            opts="$opts --no-color"
            ;;
        f)
            do_follow=1
            ;;
        w) # all branches
            wordwise=1
            opts="$opts -w -U0 --word-diff-regex=[^[:space:]] --word-diff=color"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

root=`git root`
export GIT_WORK_TREE=$root

opts2=""

args=$@

if [[ "$do_follow" == "1" ]]; then
  cmd="git log -n 1 --follow $args"
  set +e
  t=`eval $cmd 2>&1`
  set -e
  if [[ "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
    args="$args $root"
  fi
  opts="$opts --follow"
fi

git diff $opts $opts2 $args

