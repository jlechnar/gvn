#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

usage() { echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1; }

#opts="--graph --abbrev=9 --abbrev-commit --decorate"
opts=""

newline=""

pager=0
comments=0
all=0
args2=""

while getopts "pgafN" o; do
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

args="$args2 $@"
root=`git root`

if [[ "$args" == "" ]]; then
  if [[ "$all" == "1" ]]; then
    args=""
  else
    args=$root
  fi
fi

if [[ "$pager" == "1" ]]; then
  git --work-tree=$root --no-pager log $opts \
    --date=format-local:'%Y-%m-%d %H:%M:%S' \
    --format=format:"$separator%nCommit: %C(03)%H%C(reset) %C(bold magenta)%d%C(reset)%nSVN:    <hash>%H</hash>%nAuthor: %C(dim blue)%<(16,trunc)%an%C(reset)%nDate:   %C(bold green)%<(19,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C(red)%s%C(reset)%n%n%C(cyan)%b%C(reset)$newline" \
    $args | \
    gvn cmd-annotate \
    | less $opts_less
else
  git --work-tree=$root --no-pager log $opts \
    --date=format-local:"%Y-%m-%d %H:%M:%S" \
    --format=format:"$separator%nCommit: %C(03)%H%C(reset) %C(bold magenta)%d%C(reset)%nSVN:    <hash>%H</hash>%nAuthor: %C(dim blue)%<(16,trunc)%an%C(reset)%nDate:   %C(bold green)%<(19,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C(red)%s%C(reset)%n%n%C(cyan)%b%C(reset)$newline" \
    $args | \
    gvn cmd-annotate
fi

