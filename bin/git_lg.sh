#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x
set -e

usage() { echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1; }

opts="--graph --abbrev=9 --abbrev-commit --decorate"

newline=""

pager=0
comments=0
all=0

while getopts "pcafn" o; do
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
        n) # with new line after comments
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

args=$@
root=`git root`

if [[ "$args" == "" ]]; then
  if [[ "$all" == "1" ]]; then
    args=""
  else
    args=$root
  fi
fi

if [[ "$comments" == "1" ]]; then
  if [[ "$pager" == "1" ]]; then
    git --work-tree=$root --no-pager log $opts \
      --date=format-local:'%Y-%m-%d %H:%M:%S' \
      --format=format:"%C(03)%>|(16)%h%C(reset) %C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)%n%n%C(white)%b%C(reset)$newline" \
      $args \
      | less $opts_less
  else
    git --work-tree=$root --no-pager log $opts \
      --date=format-local:"%Y-%m-%d %H:%M:%S" \
      --format=format:"%C(03)%>|(16)%h%C(reset) %C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)%n%n%C(white)%b%C(reset)$newline" \
      $args \
      ; echo ""
  fi
else
  if [[ "$pager" == "1" ]]; then
    git --work-tree=$root --no-pager log $opts \
      --date=format-local:'%Y-%m-%d %H:%M:%S' \
      --format=format:"%C(03)%>|(16)%h%C(reset) %C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)$newline" \
      $args \
      | less $opts_less
  else
    git --work-tree=$root --no-pager log $opts \
      --date=format-local:"%Y-%m-%d %H:%M:%S" \
      --format=format:"%C(03)%>|(16)%h%C(reset) %C(bold green)%<(19,trunc)%ad%C(reset) %C(dim blue)%<(16,trunc)%an%C(reset) %C(black)%s%C(reset) %C(bold magenta)%d%C(reset)$newline" \
      $args \
      ; echo ""
  fi
fi



