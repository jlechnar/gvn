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

while getopts "dcf" o; do
    case "${o}" in
        d)
            opts="$opts -d"
            ;;
        c)
            opts="$opts --cached"
            ;;
        f)
            do_follow=1
            ;;
#        w) # all branches
#            wordwise=1
#            opts="$opts -w -U0 --word-diff-regex=[^[:space:]] --word-diff=color"
#            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

root=`$GIT root`
export GIT_WORK_TREE=$root

opts2="--no-symlinks "

args="$@"

if [[ "$do_follow" == "1" ]]; then
  cmd="$GIT log -n 1 --follow $args"
  set +e
  t=`eval $cmd 2>&1`
  set -e
  args_addon=""
  if [[ "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
    args_addon="$root"
  fi

  nr_files=`$GIT ls-files | grep -c .`
  if [[ "$nr_files" == "1" ]]; then
    args="$args $args_addon"
    opts="$opts --follow"
  fi

#  cmd="$GIT log -n 1 --follow $args"
#  cmd2="$GIT grep $args"
#  set +e
#  t=`eval $cmd 2>&1`
#  t2=`eval $cmd2 2>&1`
#  t2="$?"
#  set -e
#
#  # grep passes if multiple pathspecs are given or one valid
#  # grep fails with exit code 128 if no pathspec given
#  # case 1
#  #   empty => 128 and log issue => use follow
#  # case 2
#  #   valid grep and no log issue => use follow
#  # case 3
#  #   valid grep and log issue => multiple paths => do not use follow
#
#  if [[ "$t2" != "128" && "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
#    true
#  else
#    if [[ "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
#      args="$args $root"
#    fi
#    opts="$opts --follow"
#  fi
fi

$GIT difftool $opts $opts2 $args

