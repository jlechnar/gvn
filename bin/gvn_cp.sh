#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


# usage: gvn-cherry-pick <hash>

set -x
set -e

$GIT check-for-unexpected-local-changes

svn_remote_commit_to_pick="$1"
svn_url=`$GIT log $svn_remote_commit_to_pick^..$svn_remote_commit_to_pick | grep git-svn-id | $GIT awk2 | sed "s,@, r,g" | $GIT awk1`
svn_rev=`$GIT log $svn_remote_commit_to_pick^..$svn_remote_commit_to_pick | grep git-svn-id | $GIT awk2 | sed "s,@, r,g" | $GIT awk2`
svn_project=`$GIT branch -r --contains $svn_remote_commit_to_pick --no-color | $GIT awk1`
svn_commit_message=`$GIT log -n 1 --format=format:'%B' $svn_remote_commit_to_pick | egrep -v "git-svn-id"`

echo "CP: $svn_url $svn_rev $svn_project"

$GIT cherry-pick $svn_remote_commit_to_pick -n

if [[ $? == 0 ]]; then
  anything_to_commit=`$GIT status --untracked-files=no --porcelain`
  if [[ "$anything_to_commit" == "" ]]; then
    echo -e "\nINFO: Cherry-Pick did not change anything. Nothing to commit.\n"
  else
    $GIT commit -a -m "$(echo -e \"[CP: $svn_project $svn_rev] $svn_commit_message \n\n [CPE: $svn_project $svn_rev $svn_url]\")"
  fi
else
  echo -e "\nWARNING: Manual rework required. Run gvn-cp-cont.sh when finished.\n"
  $GIT status -uno
  echo -e "git commit -a -m \"$(echo -e \"[CP: $svn_project $svn_rev (modified)] $svn_commit_message \n\n [CPE: $svn_project $svn_rev $svn_url]\")\"" > gvn-cp-cont.sh
  cat gvn-cp-cont.sh
fi
