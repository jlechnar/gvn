#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# Setup: add alias to this file as follows so that wrapper's can work
# e.g. for bash:
# alias git='~/bin/git.sh'
# Note that in sub shells the alias is not active, hence we can directly call git rebase/merge/grep/... .

GVN_HISTORY=`git config gvn.history.enable || true`
GVN_HISTORY_FILE=`git config gvn.history.filename || true`
GVN_HISTORY_FILE_LENGTH=`git config gvn.history.length || true`

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

# activate below to debug commands that are executed
if [[ "$GVN_DEBUG_CMD" == "1" ]]; then
  CMD_DEBUG=1
  GIT_ENV=`echo $GIT || true`
  if [[ "$GIT_ENV" == "" ]]; then
    git_bin=`realpath ~/bin/git.sh`
    export GIT="$git_bin"
  fi
  GVN_ENV=`echo $GVN || true`
  if [[ "$GVN_ENV" == "" ]]; then
    gvn_bin=`realpath ~/bin/gvn.sh`
    export GVN="$gvn_bin"
  fi
else
  CMD_DEBUG=0
  if [[ "$GVN_HISTORY" == "1" ]]; then
    GIT_ENV=`echo $GIT || true`
    if [[ "$GIT_ENV" == "" ]]; then
      git_bin=`realpath ~/bin/git.sh`
      export GIT="$git_bin"
    fi
    GVN_ENV=`echo $GVN || true`
    if [[ "$GVN_ENV" == "" ]]; then
      gvn_bin=`realpath ~/bin/gvn.sh`
      export GVN="$gvn_bin"
    fi
  else
    export GIT="git"
    export GVN="gvn"
  fi
fi

#set -x
set -e

first=1
opt=""
cmd=""
whitespace="[[:space:]]"
for i in "$@"
do
    if [[ $i =~ $whitespace ]]
    then
        i=\"$i\"
    fi

    if [[ "$first" == "1" ]]; then
      first=0
      cmd=$i
    else
      opt="$opt $i"
    fi
done

if [[ "$cmd" == "rebase" ]]; then
  cmd2="git rebase-wrapper $opt"
elif [[ "$cmd" == "merge" ]]; then
  cmd2="git merge-wrapper $opt"
elif [[ "$cmd" == "rebase-notag" ]]; then
  cmd2="git rebase-notag $opt"
else
  cmd2="git $cmd $opt"
fi

if [[ "$CMD_DEBUG" == "1" ]]; then
  echo "GVN_CMD (GIT): $cmd2" >> /dev/stderr
fi

if [[ "$GVN_HISTORY" == "1" ]]; then
  GVN_HISTORY_FILE2=$GVN_HISTORY_FILE
  GVN_HISTORY_FILE=`eval echo $GVN_HISTORY_FILE2`

  echo "LS:  -----------------------------" >> $GVN_HISTORY_FILE
  cwd=`pwd`
  datetime=`date +'%Y.%m.%d %H:%M:%S'`
  echo "DT:  $datetime" >> $GVN_HISTORY_FILE
  echo "PWD: $cwd"      >> $GVN_HISTORY_FILE
  echo "CMD: $cmd2"     >> $GVN_HISTORY_FILE
  echo "$(tail -n $GVN_HISTORY_FILE_LENGTH $GVN_HISTORY_FILE | tr -d '\0')" > $GVN_HISTORY_FILE
fi

eval $cmd2
