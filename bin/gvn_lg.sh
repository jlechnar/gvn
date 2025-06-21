#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

WIDTH_AUTHOR=`$GIT config gvn.lg.width-author || true`
WIDTH_AUTHOR_DATE=`$GIT config gvn.lg.width-author-date || true`
WIDTH_GRAPH=`$GIT config gvn.lg.width-graph || true`
WIDTH_ABBREVIATED_HASH=`$GIT config gvn.lg.width-abbreviated-hash || true`

ABBREVIATED_HASH=`$GIT config gvn.all.width-abbreviated-hash || true`
COLOR_DATE_TIME=`$GIT config gvn.all.color-date-time || true`
COLOR_AUTHOR=`$GIT config gvn.all.color-author || true`
COLOR_REF_NAMES=`$GIT config gvn.all.color-ref-names || true`

COLOR_SUBJECT=`$GIT config gvn.lg.color-subject || true`
COLOR_BODY=`$GIT config gvn.lg.color-body || true`

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

usage() { echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1; }

opts="--graph --abbrev=$ABBREVIATED_HASH --abbrev-commit --decorate"

do_follow=1

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
            do_follow=0
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
root=`$GIT root`


if [[ "$do_follow" == "1" ]]; then
  cmd="$GIT log -n 1 --follow $args"
  set +e
  t=`eval $cmd 2>&1`
  set -e
  args_addon=""
  if [[ "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
    args_addon="$root"
  fi

  nr_files=`$GIT ls-files | grep -c .`
  if [[ "$nr_files" == "1" ]]; then
    args="$args $args_addon"
    opts="$opts --follow"
  fi

#  cmd="$GIT log -n 1 $opts --follow $args"
#  set +e
#  t=`eval $cmd 2>&1`
#  set -e
#  if [[ "$t" =~ "fatal: --follow requires exactly one pathspec" ]]; then
#    args="$args $root"
#  fi
#  opts="$opts --follow"
fi


wt="--work-tree=$root"
if [[ "$root" == "" ]]; then
  wt=""
fi

if [[ $is_gvn ]]; then
  hashfmt="<hash>%H</hash> "
  annotate="$GVN cmd-annotate"
  end_cmd=""
else
  hashfmt=""
  annotate="grep ^"
  end_cmd="echo ''"
fi

if [[ "$comments" == "1" ]]; then
  if [[ "$pager" == "1" ]]; then
    $GIT $wt --no-pager log $opts \
      --date=format-local:'%Y-%m-%d %H:%M:%S' \
      --format=format:"%C($WIDTH_GRAPH)%>|($WIDTH_ABBREVIATED_HASH)%h%C(reset) ${hashfmt}%C($COLOR_DATE_TIME)%<($WIDTH_AUTHOR_DATE,trunc)%ad%C(reset) %C($COLOR_AUTHOR)%<($WIDTH_AUTHOR,trunc)%an%C(reset) %C($COLOR_SUBJECT)%s%C(reset) %C($COLOR_REF_NAMES)%d%C(reset)%n%n%C($COLOR_BODY)%b%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate | \
      less $opts_less
  else
    $GIT $wt --no-pager log $opts \
      --date=format-local:"%Y-%m-%d %H:%M:%S" \
      --format=format:"%C($WIDTH_GRAPH)%>|($WIDTH_ABBREVIATED_HASH)%h%C(reset) ${hashfmt}%C($COLOR_DATE_TIME)%<($WIDTH_AUTHOR_DATE,trunc)%ad%C(reset) %C($COLOR_AUTHOR)%<($WIDTH_AUTHOR,trunc)%an%C(reset) %C($COLOR_SUBJECT)%s%C(reset) %C($COLOR_REF_NAMES)%d%C(reset)%n%n%C($COLOR_BODY)%b%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate
    #eval $end_cmd
  fi
else
  if [[ "$pager" == "1" ]]; then
    $GIT $wt --no-pager log $opts \
      --date=format-local:'%Y-%m-%d %H:%M:%S' \
      --format=format:"%C($WIDTH_GRAPH)%>|($WIDTH_ABBREVIATED_HASH)%h%C(reset) ${hashfmt}%C($COLOR_DATE_TIME)%<($WIDTH_AUTHOR_DATE,trunc)%ad%C(reset) %C($COLOR_AUTHOR)%<($WIDTH_AUTHOR,trunc)%an%C(reset) %C($COLOR_SUBJECT)%s%C(reset) %C($COLOR_REF_NAMES)%d%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate | \
      grep -v '^$' | \
      less $opts_less
  else
    $GIT $wt --no-pager log $opts \
      --date=format-local:"%Y-%m-%d %H:%M:%S" \
      --format=format:"%C($WIDTH_GRAPH)%>|($WIDTH_ABBREVIATED_HASH)%h%C(reset) ${hashfmt}%C($COLOR_DATE_TIME)%<($WIDTH_AUTHOR_DATE,trunc)%ad%C(reset) %C($COLOR_AUTHOR)%<($WIDTH_AUTHOR,trunc)%an%C(reset) %C($COLOR_SUBJECT)%s%C(reset) %C($COLOR_REF_NAMES)%d%C(reset)$newline" \
      $args | \
      grep -v '^...$' | \
      $annotate |
      grep -v '^$'
    #eval $end_cmd
  fi
fi



