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

opts="--graph --abbrev=9 --abbrev-commit --decorate"

newline=""

pager=0
comments=0
all=0

while getopts "pcafN" o; do
    case "${o}" in
        p)
            pager=1
            ;;
        c) # all branches
            comments=1
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


opts_less=-FSRX
#opts_less=-SRX

args="$@"
root=`git root`


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
  hashfmt="<hash>%H</hash> "
  annotate="gvn cmd-annotate"
  end_cmd=""
else
  hashfmt=""
  annotate="grep ^"
  end_cmd="echo ''"
fi

if [[ "$comments" == "1" ]]; then
  if [[ "$pager" == "1" ]]; then
    git $wt --no-pager log $opts \
      --date=format-local:'%Y-%m-%d %H:%M:%S' \
      --format=format:"%C(03)%>|(16)%h%C(reset) ${hashfmt}%C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)%n%n%C(white)%b%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate | \
      less $opts_less
  else
    git $wt --no-pager log $opts \
      --date=format-local:"%Y-%m-%d %H:%M:%S" \
      --format=format:"%C(03)%>|(16)%h%C(reset) ${hashfmt}%C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)%n%n%C(white)%b%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate
    #eval $end_cmd
  fi
else
  if [[ "$pager" == "1" ]]; then
    git $wt --no-pager log $opts \
      --date=format-local:'%Y-%m-%d %H:%M:%S' \
      --format=format:"%C(03)%>|(16)%h%C(reset) ${hashfmt}%C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate | \
      grep -v '^$' | \
      less $opts_less
  else
    git $wt --no-pager log $opts \
      --date=format-local:"%Y-%m-%d %H:%M:%S" \
      --format=format:"%C(03)%>|(16)%h%C(reset) ${hashfmt}%C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate |
      grep -v '^$'
    #eval $end_cmd
  fi
fi




