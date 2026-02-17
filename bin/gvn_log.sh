#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

if [[ -n "${GVN_CONFIG_SH_OVERRIDE}" ]]; then
  source $GVN_CONFIG_SH_OVERRIDE
else
  SCRIPT_DIR_REAL=`realpath $0`
  SCRIPT_DIR=`dirname $SCRIPT_DIR_REAL`
  source $SCRIPT_DIR/config.sh
fi

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

usage() { echo "Usage: $0 <-p: pager> <-c: comments> <-a: all> <-f: filenames> <-n: additional newline> ..." 1>&2; exit 1; }

opts=""

do_follow=1

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


# only full color support with -r ?
#opts_less=-FSRX
opts_less=-FSrX
#opts_less=-SRX

root=`$GIT root`

args="$@"


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
fi


wt="--work-tree=$root"
if [[ "$root" == "" ]]; then
  wt=""
fi

if [[ $is_gvn ]]; then
  dot_git_path=`$GIT get-dot-git-path-abs`

  hashfmt="SVN:    <hash>%H</hash>%n"
  color_expanded=`echo " $GVN_ALL__COLOR_SVN_REVISION" | sed -r 's,\s+, -c ,g'`
  annotate_opts="$color_expanded"
  rev_maps=`find $dot_git_path/svn/refs/remotes -name *.rev_map.* -type f -printf ' -r %p'`
  annotate="$GVN cmd-annotate $rev_maps"
else
  hashfmt=""
  annotate_opts=""
  annotate="grep ^"
fi


separator="------------------------------------------------"

if [[ "$pager" == "1" ]]; then
  $GIT --work-tree=$root --no-pager log $opts \
    --date=format-local:'%Y-%m-%d %H:%M:%S' \
    --format=format:"$separator%nCommit: %C($GVN_LOG__WIDTH_GRAPH)%H%C(reset) %C($GVN_ALL__COLOR_REF_NAMES)%d%C(reset)%n${hashfmt}Author: %C($GVN_ALL__COLOR_AUTHOR)%<($GVN_LOG__WIDTH_AUTHOR,trunc)%an%C(reset)%nDate:   %C($GVN_ALL__COLOR_DATE_TIME)%<($GVN_LOG__WIDTH_AUTHOR_DATE,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C($GVN_LOG__COLOR_SUBJECT)%s%C(reset)%n%n%C($GVN_LOG__COLOR_BODY)%b%C(reset)$newline" \
    $args | \
    $annotate $annotate_opts \
    | less $opts_less
else
  $GIT --work-tree=$root --no-pager log $opts \
    --date=format-local:"%Y-%m-%d %H:%M:%S" \
    --format=format:"$separator%nCommit: %C($GVN_LOG__WIDTH_GRAPH)%H%C(reset) %C($GVN_ALL__COLOR_REF_NAMES)%d%C(reset)%n${hashfmt}Author: %C($GVN_ALL__COLOR_AUTHOR)%<($GVN_LOG__WIDTH_AUTHOR,trunc)%an%C(reset)%nDate:   %C($GVN_ALL__COLOR_DATE_TIME)%<($GVN_LOG__WIDTH_AUTHOR_DATE,trunc)%ad%C(reset)%nTitle:  %w(100,0,8)%C($GVN_LOG__COLOR_SUBJECT)%s%C(reset)%n%n%C($GVN_LOG__COLOR_BODY)%b%C(reset)$newline" \
    $args | \
    $annotate $annotate_opts
  echo $separator
fi
