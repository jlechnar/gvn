#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn


if [[ "$GVN_DEBUG_GVN" == "1" || "$GVN_DEBUG_ALL" == "1" ]]; then
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
if [[ "$GVN_CMD_DEBUG" == "1" ]]; then
  CMD_DEBUG=1
else
  CMD_DEBUG=0
fi

set -e

# ---------------------------
do_clone() {
  from=$1
  to=$2
  opts=$3

  set +e
  git svn clone $from $to $opts
  cwd=`pwd`

  # repeat some times in case server connection is lost due to to fast fetching during above clone
  cd $to
  for ((n=0;n<10;n++)); do
    git svn fetch
  done
  cd $cwd
}

# ---------------------------
cmd=$1
shift

if [[ "$cmd" == "clone" ]]; then
  path=$1
  shift
  to=$1
  # we need to get rid of /trunk for full clone with all branches !
  from=`echo $path | sed 's,/trunk$,,g' | sed 's,/trunk/$,,g'`
  if [[ "$to" == "" ]]; then
    to="."
  fi

  do_clone $from $to "-s"
  # git branch -m trunk
elif [[ "$cmd" == "clone-none-standard" || "$cmd" == "clone-ns" || "$cmd" == "clone-none-std" ]]; then
  from=$1
  shift
  to=$1
  if [[ "$to" == "" ]]; then
    to="."
  fi

  do_clone $from $to ""
else
  opt=$@

  if [[ "$CMD_DEBUG" == "1" ]]; then
    echo "GVN_CMD: gvn $cmd $opt" >> /dev/stderr
  fi

  if [[ "$cmd" == "hash" || "$cmd" == "convert-hashes" || "$cmd" == "cmd-convert-hashes" ]]; then
    # do not map done by gvn_hash.sh
    true
  elif [[ "$opt" =~ ^.*r[0-9]+.*$ ]]; then
    #echo "revision detected"
    opt2=$opt
    opt=`gvn convert-hashes -c "$cmd" "$opt2"`
  fi

  git gvn-$cmd $opt
fi

