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

usage() { echo "Usage: $0 <-a: all>" 1>&2; exit 1; }

opts="-vv --abbrev=$GVN_ALL__WIDTH_ABBREVIATED_HASH"

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
