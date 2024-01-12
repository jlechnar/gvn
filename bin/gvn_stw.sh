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

root=`git root`

printf '%10s %11s   %-15s %s\n' "Unpushed" "Modifed" "branch" "worktree-path"

wtbs=`git wl | perl -pe 's,^(.+)\[([^\]]+)\]\s*$,$2\n,g'`
for wtb in $wtbs; do
  wtbp=`git worktree-get-path $wtb`
  wtgd=`git worktree-get-path-git-dir $wtb`
  nr_changed_files=`git --git-dir=$wtgd --work-tree=$wtbp diff --name-only | wc -l`
  nr_changed_files_cached=`git --git-dir=$wtgd --work-tree=$wtbp diff --name-only --cached | wc -l`
  nr_not_pushed_svn_commits=`git --no-pager log --format=format:"<hash>%H</hash>" $wtb | gvn cmd-annotate | egrep -c 'r\?'` || true
  printf '%10d %11s   %-15s %s\n' $nr_not_pushed_svn_commits "$nr_changed_files_cached/$nr_changed_files" $wtb $wtbp
done

