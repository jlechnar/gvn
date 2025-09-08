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
merge_diff=0
merge_case=""

while getopts "m:icNfwbBWls" o; do
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
        l)
            opts="$opts --name-only"
            ;;
        s)
            opts="$opts --name-status"
            ;;
        m)
            merge_diff=1
            merge_case=${OPTARG}
            ;;
        f)
            do_follow=1
            ;;
        b)
            opts="$opts -b -U0 --word-diff=color"
            ;;
        w)
            opts="$opts -w -U0 --word-diff-regex=[^[:space:]] --word-diff=color"
            ;;
        B)
            opts="$opts -b -U3 --word-diff=color"
            ;;
        W)
            opts="$opts -w -U3 --word-diff-regex=[^[:space:]] --word-diff=color"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

root=`$GIT root`
export GIT_WORK_TREE=$root

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

if [[ "$merge_diff" == "1" ]]; then
  rebase_in_progress=`git rebase-in-progress`
  merge_in_progress=`git merge-in-progress`

  a="================================================================================"; \

  if [[ "$rebase_in_progress" == "1" ]]; then
    case "$merge_case" in
      "theirs") opts="$opts -2" ;;
      "base")   opts="$opts -1" ;;
      "ours")   opts="$opts -3" ;;
      "all")    echo -e "$a\n$a\nMERGE REBASE - BASE\n$a"
                $GIT diff $opts -1 $args
                echo -e "$a\n$a\nMERGE REBASE - OURS\n$a"
                $GIT diff $opts -3 $args
                echo -e "$a\n$a\nMERGE REBASE - THEIRS\n$a"
                $GIT diff $opts -2 $args
                echo -e "$a"
                exit 0
                ;;
      *)        echo "ERROR: Unsupported merge case "$merge_case". Aborting operation."
                exit -1
                ;;
    esac
  elif [[ "$merge_in_progress" == "1" ]]; then
    case "$merge_case" in
      "theirs") opts="$opts -3" ;;
      "base")   opts="$opts -1" ;;
      "ours")   opts="$opts -2" ;;
      "all")    echo -e "$a\n$a\nMERGE - BASE\n$a"
                $GIT diff $opts -1 $args
                echo -e "$a\n$a\nMERGE - OURS\n$a"
                $GIT diff $opts -2 $args
                echo -e "$a\n$a\nMERGE - THEIRS\n$a"
                $GIT diff $opts -3 $args
                echo -e "$a"
                exit 0
                ;;
      *)        echo "ERROR: Unsupported merge case "$merge_case". Aborting operation."
                exit -1
                ;;
    esac
  else
    echo "ERROR: There is no merge nor rebase in progress. Aborting operation."
    exit -1
  fi
fi

$GIT diff $opts $args

