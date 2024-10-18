#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


# usage: gvn-cherry-pick <hash>

set -x
set -e

git check-for-unexpected-local-changes

svn_remote_commit_to_pick="$1"
svn_url=`git log $svn_remote_commit_to_pick^..$svn_remote_commit_to_pick | grep git-svn-id | git awk2 | sed "s,@, r,g" | git awk1`
svn_rev=`git log $svn_remote_commit_to_pick^..$svn_remote_commit_to_pick | grep git-svn-id | git awk2 | sed "s,@, r,g" | git awk2`
svn_project=`git branch -r --contains $svn_remote_commit_to_pick --no-color | git awk1`
svn_commit_message=`git log -n 1 --format=format:'%B' $svn_remote_commit_to_pick | egrep -v "git-svn-id"`

echo "CP: $svn_url $svn_rev $svn_project"

git cherry-pick $svn_remote_commit_to_pick -n

if [[ $? == 0 ]]; then
  anything_to_commit=`git status --untracked-files=no --porcelain`
  if [[ "$anything_to_commit" == "" ]]; then
    echo -e "\nINFO: Cherry-Pick did not change anything. Nothing to commit.\n"
  else
    git commit -a -m "$(echo -e \"[CP: $svn_project $svn_rev] $svn_commit_message \n\n [CPE: $svn_project $svn_rev $svn_url]\")"
  fi
else
  echo -e "\nWARNING: Manual rework required. Run gvn-cp-cont.sh when finished.\n"
  git status -uno
  echo -e "git commit -a -m \"$(echo -e \"[CP: $svn_project $svn_rev (modified)] $svn_commit_message \n\n [CPE: $svn_project $svn_rev $svn_url]\")\"" > gvn-cp-cont.sh
  cat gvn-cp-cont.sh
fi
