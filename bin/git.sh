#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# Setup: add alias to this file as follows so that wrapper's can work
# e.g. for bash:
# alias git='~/bin/git.sh'
# Note that in sub shells the alias is not active, hence we can directly call git rebase/merge/grep/... .

if [[ "$GVN_DEBUG_GIT" == "1" || "$GVN_DEBUG_ALL" == "1" ]]; then
  set -x
  export GIT_TRACE=2
  export GIT_CURL_VERBOSE=2
  export GIT_TRACE_PERFORMANCE=2
  export GIT_TRACE_PACK_ACCESS=2
  export GIT_TRACE_PACKET=2
  export GIT_TRACE_PACKFILE=2
  export GIT_TRACE_SETUP=2
  export GIT_TRACE_SHALLOW=2
fi
if [[ "$GVN_DEBUG_ALL" == "1" ]]; then
  export GVN_DEBUG=1
fi
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

