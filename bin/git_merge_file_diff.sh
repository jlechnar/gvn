#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# merge-file-diff
# note that depending on merge OR rebase-merge ours/theis exchange in show/diff commands automatically
# automatic detecting rebase-merges helps to avoid confusion
# with ours in below commands always our/mine changes are meant independent on merge operation type

set -e

file=$1

rebase_in_progress=`git rebase-in-progress`
merge_in_progress=`git merge-in-progress`

file_path=`realpath $file`
main_path=`git rev-parse --path-format=absolute --show-toplevel`
file_path_relative_to_main_path=`realpath --relative-to=$main_path $file_path`

cd $main_path

if [[ "$rebase_in_progress" == "1" ]]; then
  git show :1:$file_path_relative_to_main_path > $file_path_relative_to_main_path.MR_BASE
  git show :2:$file_path_relative_to_main_path > $file_path_relative_to_main_path.MR_THEIRS
  git show :3:$file_path_relative_to_main_path > $file_path_relative_to_main_path.MR_OURS
elif [[ "$merge_in_progress" == "1" ]]; then
  git show :1:$file_path_relative_to_main_path > $file_path_relative_to_main_path.M_BASE
  git show :2:$file_path_relative_to_main_path > $file_path_relative_to_main_path.M_OURS
  git show :3:$file_path_relative_to_main_path > $file_path_relative_to_main_path.M_THEIRS
else
  echo "ERROR: There is no merge nor rebase in progress. Aborting operation."
  exit -1
fi
