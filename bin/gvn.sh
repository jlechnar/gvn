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
if [[ "$GVN_DEBUG_CMD" == "1" ]]; then
  CMD_DEBUG=1
  git_bin=`realpath ~/bin/git.sh`
  export GIT="$git_bin"
else
  CMD_DEBUG=0
  export GIT="git"
fi

set -e

# ---------------------------
do_clone() {
  from=$1
  to=$2
  opts=$3

  set +e
  cmd2="$GIT svn clone $from $to $opts"
  eval $cmd2
  cwd=`pwd`

  # repeat some times in case server connection is lost due to to fast fetching during above clone
  cd $to
  for ((n=0;n<10;n++)); do
    cmd2="$GIT svn fetch"
    eval $cmd2
  done
  gvn umdb
  cd $cwd
}

# ---------------------------
first=1
opt=""
cmd=""
whitespace="[[:space:]]"
all=$@
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

# set -x

if [[ "$cmd" == "clone" ]]; then
  a=$all
  shift
  path=$1
  shift
  to=$1

  # <prefix>/<version/module>/trunk/...
  # <prefix>/<version/module>/branches/<branch_name>/...
  # <prefix>/<version/module>/tags/<tag_name>/...

  # we need to get rid of /trunk for full clone with all branches !
  from=`echo $path | sed 's,/trunk$,,g' | sed 's,/trunk/$,,g'`
  if [[ "$to" == "" ]]; then
    to="."
  fi

  opts="-s"

  do_clone $from $to $opts
  # git branch -m trunk
elif [[ "$cmd" == "clone2" ]]; then
  a=$all
  shift
  path=$1
  shift
  to=$1

  # <prefix>/trunk/<version/module>/...
  # <prefix>/branches/<version/module>/<branch_name>/...
  # <prefix>/tags/<version/module>/<tag_name>/...

  prefix=`echo $path | perl -pe "s,^(.+)/(trunk|branches|tags)/,\$1,g"`
  name=`echo $path | perl -pe "s,^.+/(trunk|branches|tags)/,,g" | sed 's,/, ,g' | awk '{print $1}'`
  trunk="$prefix/trunk/$name"
  tags="$prefix/tags/$name"
  branches="$prefix/branches/$name"

  from=$trunk
  if [[ "$to" == "" ]]; then
    to="."
  fi

  opts="--trunk $trunk --tags $tags --branches $branches"

  do_clone $from $to $opts
  # git branch -m trunk

elif [[ "$cmd" == "clone-none-standard" || "$cmd" == "clone-ns" || "$cmd" == "clone-none-std" ]]; then
  a=$all
  shift
  from=$1
  shift
  to=$1

  # just use the path, no tags/branches at all - only like a single trunk

  if [[ "$to" == "" ]]; then
    to="."
  fi
  opts=""

  do_clone $from $to $opts
else
  if [[ "$cmd" == "hash" || "$cmd" == "convert-hashes" || "$cmd" == "cmd-convert-hashes" ]]; then
    # do not map done by gvn_hash.sh
    true
  elif [[ "$opt" =~ r[0-9]+ ]]; then
    #echo "revision detected"
    opt2=$opt
    opt=`gvn convert-hashes -c "$cmd" "$opt2"`
    if [[ "$CMD_DEBUG" == "1" ]]; then
      echo "SVN2GIT version convert: $opt2 => $opt"
    fi
  fi

  if [[ `git al | grep gvn-$cmd` == "" ]]; then
    cmd2="$GIT $cmd $opt"
  else
    cmd2="$GIT gvn-$cmd $opt"
  fi

  if [[ "$CMD_DEBUG" == "1" ]]; then
    echo "GVN_CMD (GVN): $cmd2" >> /dev/stderr
  fi

  eval $cmd2
fi

