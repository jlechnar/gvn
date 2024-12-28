#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

usage() { echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1; }

#opts="--graph --abbrev=9 --abbrev-commit --decorate"
opts=""

newline=""

pager=0
comments=0
all=0
args2=""

while getopts "pgafNC" o; do
    case "${o}" in
        p)
            pager=1
            ;;
        g)  # graph
            opts="--graph $opts"
            ;;
        a) # all branches
            opts="--all $opts"
            all=1
            ;;
        f) # with file names
            opts="--name-status $opts"
            ;;
        N) # with new line after comments
            newline="%n"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


# only full color support with -r ?
#opts_less=-FSRX
opts_less=-FSrX
#opts_less=-SRX

root=`git root`

args="$@"


if [[ "$all" == "0" ]]; then
  cmd="git log -n 1 $opts --follow $args"
  set +e
  t=`eval $cmd 2>&1`
  set -e
  if [[ "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
    args="$args $root"
  fi
  opts="$opts --follow"
fi


wt="--work-tree=$root"
if [[ "$root" == "" ]]; then
  wt=""
fi

if [[ $is_gvn ]]; then
  hashfmt="SVN:    <hash>%H</hash>%n"
  annotate="gvn cmd-annotate"
  end_cmd=""
else
  hashfmt=""
  annotate="grep ^"
  end_cmd="echo ''; echo '$separator'"
fi

#     --format=format:"------------------------------------------------%nCommit: %C(03)%H%C(reset) %C(bold magenta)%d%C(reset)%nAuthor: %C(dim blue)%<(16,trunc)%an%nDate:   %C(bold green)%<(19,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C(red)%s%C(reset)%n%n%C(cyan)%b%C(reset)$newline" \

separator="------------------------------------------------"

if [[ "$pager" == "1" ]]; then
  git --work-tree=$root --no-pager log $opts \
    --date=format-local:'%Y-%m-%d %H:%M:%S' \
    --format=format:"$separator%nCommit: %C(03)%H%C(reset) %C(bold magenta)%d%C(reset)%n${hashfmt}Author: %C(dim blue)%<(16,trunc)%an%C(reset)%nDate:   %C(bold green)%<(19,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C(red)%s%C(reset)%n%n%C(cyan)%b%C(reset)$newline" \
    $args | \
    $annotate \
    | less $opts_less
else
  git --work-tree=$root --no-pager log $opts \
    --date=format-local:"%Y-%m-%d %H:%M:%S" \
    --format=format:"$separator%nCommit: %C(03)%H%C(reset) %C(bold magenta)%d%C(reset)%n${hashfmt}Author: %C(dim blue)%<(16,trunc)%an%C(reset)%nDate:   %C(bold green)%<(19,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C(red)%s%C(reset)%n%n%C(cyan)%b%C(reset)$newline" \
    $args | \
    $annotate
  echo $separator
  #$end_cmd
fi

