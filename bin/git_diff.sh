#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

#git diff --follow $@ | xargs -I '{}' realpath --relative-to=. $(git rev-parse --show-toplevel)/'{}'

usage() { # echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1;
  echo "FIXME"
  exit -1
}

opts=""

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
            opts="$opts --follow"
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

opts2=""

# on empty args use local folder
if [[ -z $@ ]]; then
  opts2="$root"
fi

git diff $opts $opts2 $@

