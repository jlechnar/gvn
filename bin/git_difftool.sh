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

opts=""

while getopts "dcf" o; do
    case "${o}" in
        d)
            opts="$opts -d"
            ;;
        c)
            opts="$opts --cached"
            ;;
        f)
            opts="$opts --follow"
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

root=`git root`

opts2=""

# on empty args use local folder
if [[ -z $@ ]]; then
  opts2="$root"
fi

git difftool $opts $opts2 $@

