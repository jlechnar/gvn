#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

branch=$1
remote=$2

if [[ -e $dot_git_path_abs/svn/.metadata ]]; then
  echo "ERROR: Detected repository to be a git-svn folder. Push not supported. Aborting.";
  exit -1
fi

if [[ "$#" == "1" ]]; then
  remote=$branch
  branch=`git get-current-branch`
  git push -u $remote $branch
elif [[ "$#" == "2" ]]; then
  git push -u $remote $branch
else
  echo "ERROR: Unexpected number of parameters, expected is {<branch> <remote>} OR {<remote>}"
  exit -1
fi

