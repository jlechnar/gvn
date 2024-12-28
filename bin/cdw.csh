
# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# FIXME: below fails due to missing define for GVN_DEBUG_CDW in check if not exported => commented for now
#if ( "$GVN_DEBUG_CDW" == "1" || "$GVN_DEBUG_ALL" == "1" ) then
#  set verbose
#  set echo
#endif

#
# add alias to ~/.cshrc pointing to this file:
#
# alias cdw 'set argv = ( \!* ) ; source ~/bin/gvn/cdw.csh'
#

# <base_path>/<act_branch>/<sub_dir>  =>  <base_path>/new_branch/<sub_dir>

set new_branch="$1"
set new_base_path=`git worktree-branch-get-path $new_branch | xargs realpath`

set act_cwd=`pwd | xargs realpath`
set act_branch=`git rev-parse --abbrev-ref HEAD`
set act_base_path=`git worktree-branch-get-path $act_branch | xargs realpath`
set act_sub_path=`echo $act_cwd | sed "s,$act_base_path,,g" | sed 's,^/,,g'`

set new_cwd="$new_base_path/$act_sub_path"

if ( "$new_base_path" == "" ) then
  echo "ERROR: Could not find worktree branch named <$new_branch>. Aborting."
else if ( -d $new_cwd ) then
  echo "Found git worktree with existing subfolder"
  echo "branch:     $act_branch => $new_branch"
  echo "base_paths: $act_base_path => $new_base_path"
  echo "paths:      $act_cwd => $new_cwd"
  cd $new_cwd
  pwd
else if ( -d $new_base_path ) then
  echo "Found git worktree with not existing subfolder"
  echo "branch:     $act_branch => $new_branch"
  echo "base_paths: $act_base_path => $new_base_path"
  echo "paths:      $act_cwd => $new_base_path"
  cd $new_base_path
  pwd
else
  echo "Could not find matching git worktree. Aborting."
endif

