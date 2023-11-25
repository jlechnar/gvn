#!/bin/bash

set -e
set -x

CWD=$1
CWD_REAL=$2
USER=$3
file=$4

cat $file | \
  sed "s,$CWD,\.\.\.,g" | \
  sed "s,$CWD_REAL,\.\.\.,g" | \
  sed "s,$USER,<user>,g" | \
  sed 's,[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_[0-9]\{2\}_[0-9]\{2\},<DATE_TIME>,g' | \
  sed 's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},<TIME>,g' | \
  sed 's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},<DATE>,g' | \
  sed 's,[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{4\},<DATE>,g' | \
  perl -pe 's/^(r\d+\s+=\s+)[a-zA-Z0-9]+(\s+)/$1<HASH>$2/g' | \
  perl -pe 's/(\e\[[0-9;]*m\s+)[0-9a-fA-F]+(\e\[[0-9;]*m\s+\e\[[0-9;]*m\s*r\d+\s*\e\[[0-9;]*m\s+)/$1<HASH>$2/g' | \
  perl -pe 's/(\e\[[0-9;]*m\s*)[0-9a-fA-F]+(\e\[[0-9;]*m\s+\e\[[0-9;]*m\s*r\d+\s*\e\[[0-9;]*m\s+)/$1<HASH>$2/g' | \
  perl -pe 's/gvn_rebase_(\d+_\d+_\d+-\d+_\d+_\d+)_git_([0-9a-fA-F]{40})_to_svn_([0-9a-fA-F]{40})/gvn_rebase_<DATE>_<TIME>_git_<HASH>_to_svn_<HASH>/g' | \
  perl -pe 's/No changes between ([0-9a-fA-F]+) and/No changes between <HASH> and/g' | \
  perl -pe 's/gvn_worktree_merge_(\d+_\d+_\d+-\d+_\d+_\d+)_([^_])+_([0-9a-fA-F]{40})_to_([^_])+_([0-9a-fA-F]{40})/gvn_worktree_merge_<DATE>_<TIME>_$2_<HASH>_to_$4_<HASH>/g' | \
  perl -pe 's/gvn_worktree_rebase_(\d+_\d+_\d+-\d+_\d+_\d+)_([^_])+_([0-9a-fA-F]{40})_to_([^_])+_([0-9a-fA-F]{40})/gvn_worktree_rebase_<DATE>_<TIME>_$2_<HASH>_to_$4_<HASH>/g' | \
  perl -pe 's/^\[(detached\s+\S+\s+)([0-9a-fA-F]+)\]/\[$1 <HASH>\]/g' | \
  perl -pe 's/^\[(\S+\s+)([0-9a-fA-F]+)\]/\[$1 <HASH>\]/g' | \
  perl -pe 's/^\[(\S+\s+\(\S+\)\s+)([0-9a-fA-F]+)\]/\[$1<HASH>\]/g' | \
  perl -pe 's/(Saved working directory and index state WIP on \S+: )([0-9a-fA-F]+)( files)/$1<HASH>$3/g' | \
  perl -pe 's/(\d{4}_\d{2}_\d{2}-\d{2}_\d{2}_\d{2})/<DATE>_<TIME>/g' | \
  perl -pe 's/(\e\[33m\s*)([0-9a-fA-F]+)(\e\[m)/$1<HASH>$3/g' | \
  perl -pe 's/(Dropped refs\/stash\@\{\d+\} )\(([0-9a-fA-F]+)\)/$1\(<HASH>\)/g' | \
  perl -pe 's/^(\S+ is now at )([0-9a-fA-F]+)(\s|$)/$1<HASH>$3/g' | \
  perl -pe 's/^(Updating )([0-9a-fA-F]+)(\.\.)([0-9a-fA-F]+)/$1<HASH>$3<HASH>/g' | \
  perl -pe 's/^(\.\.\.\/\S+\/\S+\s+)([0-9a-fA-F]+)(\s+\[\S+\])$/$1<HASH>$3/g' | \
  perl -pe 's/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/<GIT_SVN_HASH>/g' | \
  perl -pe 's/((\e\[33m\s*)commit\s+)[0-9a-fA-F]{40}(\e\[m)/$1<HASH>$2/g' | \
  perl -pe 's/(Executing:  git (df|dfw) )([0-9a-fA-F]+)( \S+ )([0-9a-fA-F]+)(\s+\S+)/$1<HASH>$4<HASH>$6/g'

