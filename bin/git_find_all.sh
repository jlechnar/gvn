#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

tree="HEAD"

current_dir=`pwd`
root_dir=`$GIT root`


if [[ "$#" == "0" ]]; then
  search="."
elif [[ "$#" == "1" ]]; then
  search="$1"
else
  echo "ERROR: options missing - check parameters git find_all <file_name>"; \
  exit -1; \
fi

$GIT --work-tree=$root_dir ls-tree --name-only -r $tree $root_dir | egrep $search
