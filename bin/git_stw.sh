#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# status worktrees

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

cmd=$0
is_gvn=`basename $cmd | grep ^gvn_ || true`

root=`git root`

if [[ $is_gvn ]]; then
  if ! [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git folder. Use git stw instead. Aborting.";
    exit -1
  fi
else
  if [[ -e $dot_git_path_abs/svn/.metadata ]]; then
    echo "ERROR: Detected repository to be a git-svn folder. Use gvn stw instead. Aborting.";
    exit -1
  fi
fi

printf '%11s %11s   %-15s %s\n' "Unpushed" "Modifed" "branch" "worktree-path"

wtbs=`git wl | perl -pe 's,^(.+)\[([^\]]+)\]\s*$,$2\n,g'`
for wtb in $wtbs; do
  wtbp=`git worktree-branch-get-path $wtb`
  wtgd=`git worktree-branch-get-path-git-dir $wtb`
  nr_changed_files=`git --git-dir=$wtgd --work-tree=$wtbp diff --name-only | wc -l`
  nr_changed_files_cached=`git --git-dir=$wtgd --work-tree=$wtbp diff --name-only --cached | wc -l`
  if [[ $is_gvn ]]; then
    nr_not_pushed_svn_commits=`git --no-pager log --format=format:"<hash>%H</hash>" $wtb | gvn cmd-annotate | egrep -c 'r\?'` || true
    nr_unpushed="$nr_not_pushed_svn_commits"
  else
    nr_unpushed_files=`git --git-dir=$wtgd --work-tree=$wtbp nr-unpushed-files`
    nr_unpushed_commits=`git --git-dir=$wtgd --work-tree=$wtbp nr-unpushed-commits`
    nr_unpushed="$nr_unpushed_commits/$nr_unpushed_files"
  fi
  printf '%11s %11s   %-15s %s\n' "$nr_unpushed" "$nr_changed_files_cached/$nr_changed_files" $wtb $wtbp
done

