#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# $1 ... local branch name
# $2 ... remote branch name

set -e

if [ "$#" -ne 1 ]; then
  remote_name=$1
  local_name=`echo $remote_name | sed 's,/, ,g' | git awk-1`
  git checkout -b $local_name $remote_name
elif [ "$#" -ne 2 ]; then
  local_name=$1
  remote_name=$2
  git checkout -b $local_name $remote_name
else
  echo "ERROR: Unexpected number of arguments"
fi
