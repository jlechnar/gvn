#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

file=$1

rebase_in_progress=`git rebase-in-progress`
merge_in_progress=`git merge-in-progress`

file_path=`realpath $file`
main_path=`git rev-parse --path-format=absolute --show-toplevel`
file_path_relative_to_main_path=`realpath --relative-to=$main_path $file_path`

cd $main_path

if [[ "$rebase_in_progress" == "1" ]]; then
  git show :1:$file_path_relative_to_main_path > $file_path_relative_to_main_path
elif [[ "$merge_in_progress" == "1" ]]; then
  git show :1:$file_path_relative_to_main_path > $file_path_relative_to_main_path
else
  echo "ERROR: There is no merge nor rebase in progress. Aborting operation."
  exit -1
fi
