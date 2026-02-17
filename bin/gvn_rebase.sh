#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ -n "${GVN_CONFIG_SH_OVERRIDE}" ]]; then
  source $GVN_CONFIG_SH_OVERRIDE
else
  SCRIPT_DIR_REAL=`realpath $0`
  SCRIPT_DIR=`dirname $SCRIPT_DIR_REAL`
  source $SCRIPT_DIR/config.sh
fi

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

head_svn_short=`echo $head_svn | cut -c 1-$GVN_ALL__WIDTH_ABBREVIATED_HASH`
head_git_short=`echo $head_git | cut -c 1-$GVN_ALL__WIDTH_ABBREVIATED_HASH`

branch_name=`$GIT rev-parse --abbrev-ref HEAD`


datetime=`date +'%Y%m%d_%H%M%S'`
tagname="auto_${datetime}_gvn_rebase_${branch_name}"
#tagname="auto_gvn_rebase_${datetime}_git_${head_git_short}_to_svn_${head_svn_short}"
$GIT tag -a $tagname -m "$GIT svn rebase tag $datetime ($GIT $head_git rebased to svn $head_svn)"
echo "Created Tag $tagname"

$GIT $run_path svn rebase
