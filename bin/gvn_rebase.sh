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

root=""

while getopts "r:" o; do
    case "${o}" in
        r)
            root=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

run_path=""
if ! [[ "$root" == "" ]]; then
  run_path="-C $root"
fi

head_svn=`$GIT svn log --oneline --show-commit --no-abbrev --limit 1 | $GIT awk3`
head_git=`$GIT rev-parse HEAD`

datetime=`date +'%Y_%m_%d-%H_%M_%S'`
$GIT tag -a gvn_rebase_${datetime}_git_${head_git}_to_svn_${head_svn} -m "$GIT svn rebase tag $datetime ($GIT $head_$GIT rebased to svn $head_svn)"
echo "Created Tag gvn_rebase_$datetime_${datetime}_git_${head_git}_to_svn_${head_svn}"

$GIT $run_path svn rebase
