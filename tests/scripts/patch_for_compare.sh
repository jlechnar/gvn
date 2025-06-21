#!/bin/bash

set -e
set -x

CWD=$1
USER=$2
file=$3

CWD_BIN=`realpath $CWD/../bin`
CWD_REAL=`realpath $CWD`


cat $file | \
  sed "s,$CWD,\.\.\.,g" | \
  sed "s,$CWD_REAL,\.\.\.,g" | \
  sed "s,$CWD_BIN,\.\.\./../bin,g" | \
  sed "s,$USER,<user>,g" | \
  perl -pe 's/(\d{4}-\d{2}-\d{2} \d{2}\:\d{2}\:\d{2} (\+|\-|)\d+ \(\S+ \d+ \S+ \d{4}\))/<DATE>_<TIME>_<EXT>/g' | \
  sed 's,[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_[0-9]\{2\}_[0-9]\{2\},<DATE_TIME>,g' | \
  sed 's,[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\} [0-9]\{2\}\:[0-9]\{2\}\:[0-9]\{2\},<DATE_TIME>,g' | \
  sed 's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},<TIME>,g' | \
  sed 's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},<DATE>,g' | \
  sed 's,[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{4\},<DATE>,g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40})(\s+.+\s+)([0-9a-fA-F]{40})(\s+.+$)/$1<HASH>$3<HASH>$5/g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40})(\:.+\s+)([0-9a-fA-F]{40})(\:.+$)/$1<HASH>$3<HASH>$5/g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40})(\:.+\s*$)/$1<HASH>$3/g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40})(\s+.+\s*$)/$1<HASH>$3/g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40})(\s+to \S+\s+)([0-9a-fA-F]{40})(\)\")$/$1<HASH>$3<HASH>$5/g' | \
  perl -pe "s/^(Deleted tag \'[^\']+\' \(was )([0-9a-fA-F]+)(\)\s*)$/\$1<HASH>\$3/g" | 
  perl -pe "s/^(Deleted branch .+ \(was )([0-9a-fA-F]+)(\)\.\s*)$/\$1<HASH>\$3/g" | 
  perl -pe 's/^([0-9a-fA-F]{40})(\s+.+)/<HASH>$2/g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40})(.\.\.)([0-9a-fA-F]{40})/$1<HASH>$3<HASH>/g' | \
  perl -pe 's/^(CMD:.+\s+)([0-9a-fA-F]{40}$)/$1<HASH>/g' | \
  perl -pe 's/(rebased to \S+ )([0-9a-fA-F]{40})(\))/$1<HASH>$3/g' | \
  perl -pe 's/(Subproject commit )([0-9a-fA-F]{40})/$1<HASH>/g' | \
  perl -pe "s/(Submodule path '.+': checked out \')([0-9a-fA-F]{40})(')/\$1<HASH>\$3/g" | \
  perl -pe 's/^(.+interactive rebase in progress; onto .+)[0-9a-fA-F]{7}(\s*)$/$1<HASH>$2/g' | \
  perl -pe "s/^(\s*You are currently rebasing branch '.+' on ')[0-9a-fA-F]{7}('.\s*)$/\$1<HASH>\$2/g" | \
  perl -pe 's/^(\s*pick )[0-9a-fA-F]{7}( conflicting_changes\s*)$/$1<HASH>$2/g' | \
  perl -pe 's/^(   )[0-9a-fA-F]{7}(\.\.)[0-9a-fA-F]{7}(\s+.+)/$1<HASH>$2<HASH>$3/g' | \
  perl -pe 's/(\s+)[0-9a-fA-F]{7}( \(conflicting_changes\))/$1<HASH>$2/g' | \
  perl -pe 's/^(r\d+\s+=\s+)[a-zA-Z0-9]+(\s+)/$1<HASH>$2/g' | \
  perl -pe 's/(\e\[[0-9;]*m\s+)[0-9a-fA-F]+(\e\[[0-9;]*m\s+\e\[[0-9;]*m\s*r\d+\s*\e\[[0-9;]*m\s+)/$1<HASH>$2/g' | \
  perl -pe 's/(\e\[[0-9;]*m\s*)[0-9a-fA-F]+(\e\[[0-9;]*m\s+\e\[[0-9;]*m\s*r\d+\s*\e\[[0-9;]*m\s+)/$1<HASH>$2/g' | \
  perl -pe 's/gvn_rebase_(\d+_\d+_\d+-\d+_\d+_\d+)_git_([0-9a-fA-F]{40})_to_svn_([0-9a-fA-F]{40})/gvn_rebase_<DATE>_<TIME>_git_<HASH>_to_svn_<HASH>/g' | \
  perl -pe 's/git_rebase_(\d+_\d+_\d+-\d+_\d+_\d+)_\S+_([0-9a-fA-F]{40})_to_\S+_([0-9a-fA-F]{40})/git_rebase_<DATE>_<TIME>_git_<HASH>_to_svn_<HASH>/g' | \
  perl -pe 's/No changes between ([0-9a-fA-F]+) and/No changes between <HASH> and/g' | \
  perl -pe 's/gvn_worktree_merge_(\d+_\d+_\d+-\d+_\d+_\d+)_([^_]+)_([0-9a-fA-F]{40})_to_([^_]+)_([0-9a-fA-F]{40})/gvn_worktree_merge_<DATE>_<TIME>_$2_<HASH>_to_$4_<HASH>/g' | \
  perl -pe 's/gvn_worktree_rebase_(\d+_\d+_\d+-\d+_\d+_\d+)_([^_]+)_([0-9a-fA-F]{40})_to_([^_]+)_([0-9a-fA-F]{40})/gvn_worktree_rebase_<DATE>_<TIME>_$2_<HASH>_to_$4_<HASH>/g' | \
  perl -pe 's/^\[(detached\s+\S+\s+)([0-9a-fA-F]+)\]/\[$1 <HASH>\]/g' | \
  perl -pe 's/^\[(\S+\s+)([0-9a-fA-F]+)\]/\[$1 <HASH>\]/g' | \
  perl -pe 's/^\[(\S+\s+\(\S+\)\s+)([0-9a-fA-F]+)\]/\[$1<HASH>\]/g' | \
  perl -pe 's/(Saved working directory and index state WIP on \S+: )([0-9a-fA-F]+)( files)/$1<HASH>$3/g' | \
  perl -pe 's/(\d{4}_\d{2}_\d{2}-\d{2}_\d{2}_\d{2})/<DATE>_<TIME>/g' | \
  perl -pe 's/(\e\[33m\s*)([0-9a-fA-F]+)(\e\[m)/$1<HASH>$3/g' | \
  perl -pe 's/(Dropped refs\/stash\@\{\d+\} )\(([0-9a-fA-F]{40})\)/$1\(<HASH>\)/g' | \
  perl -pe 's/(Found branch parent:\s+\([^\)]+\)\s+)([0-9a-fA-F]+)/$1<HASH>/g' | \
  perl -pe 's/^(\S+ is now at )([0-9a-fA-F]+)(\s|$)/$1<HASH>$3/g' | \
  perl -pe 's/(git\s+diff\s+)([0-9a-fA-F]{40})(\:\S+\s+)([0-9a-fA-F]{40})(\:\S+)/$1<HASH>$3<HASH>$5/g' | \
  perl -pe 's/(index\s+)([0-9a-fA-F]+)(\.\.)([0-9a-fA-F]+)/$1<HASH>$3<HASH>/g' | \
  perl -pe 's/(warning: skipped previously applied commit )([0-9a-fA-F]+)/$1<HASH>/g' | \
  perl -pe 's/^(Updating )([0-9a-fA-F]+)(\.\.)([0-9a-fA-F]+)/$1<HASH>$3<HASH>/g' | \
  perl -pe 's/^(error: could not apply )([0-9a-fA-F]+)(\.\.\.)/$1<HASH>$3/g' | \
  perl -pe 's/^(Could not apply )([0-9a-fA-F]+)(\.\.\.)/$1<HASH>$3/g' | \
  perl -pe 's/^(\.\.\.\/\S+\/\S+\s+)([0-9a-fA-F]+)(\s+\[\S+\])$/$1<HASH>$3/g' | \
  perl -pe 's/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/<GIT_SVN_HASH>/g' | \
  perl -pe 's/((\e\[33m\s*)commit\s+)[0-9a-fA-F]{40}(\e\[m)/$1<HASH>$2/g' | \
  perl -pe 's/^(Date:\s+).+$/$1<DATE_TIME>/g' | \
  perl -pe 's/(...\/..\/bin\/git.sh\s+cat\s+)([0-9a-fA-F]{40})(\s+.+)/$1<HASH>$3/g' | \
  perl -pe 's/(\e\[m\s+)([0-9a-fA-F]+)(\s+(\(|\[|created |changes_))/$1<HASH>$3/g' | \
  perl -pe 's/(Executing:  ...\/..\/bin\/git.sh (df|dfw) )([0-9a-fA-F]+)( \S+ )([0-9a-fA-F]+)(\s+\S+)/$1<HASH>$4<HASH>$6/g'

