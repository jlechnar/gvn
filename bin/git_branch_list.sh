#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

ABBREVIATED_HASH=`$GIT config gvn.all.width-abbreviated-hash || true`

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

usage() { echo "Usage: $0 <-a: all>" 1>&2; exit 1; }

opts="-vv --abbrev=$ABBREVIATED_HASH"

while getopts "a" o; do
    case "${o}" in
        a)
            opts="$opts -a"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

$GIT branch $opts
