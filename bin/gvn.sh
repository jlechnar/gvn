#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

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
  git gvn-$cmd $opt
fi

