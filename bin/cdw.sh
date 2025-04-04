
if [[ "$GVN_DEBUG_CDW" == "1" || "$GVN_DEBUG_ALL" == "1" ]]; then
  set -x
fi
#set -e

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#
# add alias to ~/.bashrc pointing to this file:
#
# alias cdw='source ~/bin/bin_gvn/cdw.sh'
#

# <base_path>/<act_branch>/<sub_dir>  =>  <base_path>/new_branch/<sub_dir>

new_branch="$1"
new_base_path=`git worktree-branch-get-path $new_branch | xargs realpath`

act_cwd=`pwd | xargs realpath`
act_branch=`git rev-parse --abbrev-ref HEAD`
act_base_path=`git worktree-branch-get-path $act_branch | xargs realpath`
act_sub_path=`echo $act_cwd | sed "s,$act_base_path,,g" | sed 's,^/,,g'`

new_cwd="$new_base_path/$act_sub_path"

if [[ "$new_base_path" == "" ]]; then
  echo "ERROR: Could not find worktree branch named <$new_branch>. Aborting."
elif [ -d $new_cwd ]; then
  echo "Found git worktree with existing subfolder"
  echo "branch:     $act_branch => $new_branch"
  echo "base_paths: $act_base_path => $new_base_path"
  echo "paths:      $act_cwd => $new_cwd"
  cd $new_cwd
  pwd
elif [ -d $new_base_path ]; then
  echo "Found git worktree with not existing subfolder"
  echo "branch:     $act_branch => $new_branch"
  echo "base_paths: $act_base_path => $new_base_path"
  echo "paths:      $act_cwd => $new_base_path"
  cd $new_base_path
  pwd
else
  echo "Could not find matching git worktree. Aborting."
fi

