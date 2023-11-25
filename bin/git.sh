#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# Setup: add alias to this file as follows so that wrapper's can work
# e.g. for bash:
# alias git='~/bin/git.sh'
# Note that in sub shells the alias is not active, hence we can directly call git rebase/merge/grep/... .

set -e

cmd=$1
shift
opt=$@

if [[ "$cmd" == "rebase" ]]; then
  git rebase-wrapper $opt
elif [[ "$cmd" == "merge" ]]; then
  git merge-wrapper $opt
else
  git $cmd $opt
fi

