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

while getopts "f:" o; do
    case "${o}" in
        f)
            file_case=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

args="$@"

rebase_in_progress=`$GIT rebase-in-progress`
merge_in_progress=`$GIT merge-in-progress`

if [[ "$rebase_in_progress" == "1" ]]; then
  case "$file_case" in
    "theirs") opts="$opts --ours" ;;
    "merge")  opts="$opts --merge" ;;
    "ours")   opts="$opts --theirs" ;;
    *)        echo "ERROR: Unsupported file case "$file_case". Aborting operation."
              exit -1
              ;;
  esac
elif [[ "$merge_in_progress" == "1" ]]; then
  case "$file_case" in
    "theirs") opts="$opts --theirs" ;;
    "merge")  opts="$opts --merge" ;;
    "ours")   opts="$opts --ours" ;;
    *)        echo "ERROR: Unsupported file case "$file_case". Aborting operation."
              exit -1
              ;;
  esac
else
  echo "ERROR: There is no merge nor rebase in progress. Aborting operation."
  exit -1
fi

$GIT checkout $opts $args
