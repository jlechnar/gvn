#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#
# install: link gito to folder in PATH
# setup: change to git folder, then run "gito init"
# usage: in git folder use gito instead of git to access overlayed git structure
# 

if [[ "$GVN_DEBUG_GITO" == "1" || "$GVN_DEBUG_ALL" == "1" ]]; then
  set -x
  export GIT_TRACE=2
  export GIT_CURL_VERBOSE=2
  export GIT_TRACE_PERFORMANCE=2
  export GIT_TRACE_PACK_ACCESS=2
  export GIT_TRACE_PACKET=2
  export GIT_TRACE_PACKFILE=2
  export GIT_TRACE_SETUP=2
  export GIT_TRACE_SHALLOW=2
fi

if [[ "$GVN_DEBUG_ALL" == "1" ]]; then
  export GVN_DEBUG=1
fi

# activate below to debug commands that are executed
if [[ "$GVN_CMD_DEBUG" == "1" ]]; then
  CMD_DEBUG=1
else
  CMD_DEBUG=0
fi

set -e

GITO=$0

cmd=$1
shift
opts=$@

tmp_init_overlay_folder=".overlay"
overlay_folder=".git_overlay"
gitignore_overlay=".gitignore_overlay"
gitignore_base=".gitignore_base"

if [[ "$cmd" == "init" ]]; then
  cwd=`pwd`
  dst=$1
  if [[ "$to" == "" ]]; then
    dst="."
  fi
  cd $dst

  # -------------
  is_in_git_repo=`git rev-parse --is-inside-work-tree 2> /dev/null`

  if [ "$is_in_git_repo" != "true" ]; then
    echo "ERROR: Init aborting due to not in any git repository."
    exit -1
  fi

  git_root_path=`git root`

  cd $git_root_path

  # -------------
  if [[ -e $tmp_init_overlay_folder ]]; then
    echo "ERROR: Init aborted due to already existing temporary overlay folder ($tmp_init_overlay_folder)."
    exit -1
  fi
  
  if [[ -e $overlay_folder ]]; then
    echo "ERROR: Init aborted due to already existing git overlay folder ($overlay_folder)."
    exit -1
  fi

  # -------------
  echo "Adding overlay to git repo in $git_root_path ..."

  # -------------
  mkdir $tmp_init_overlay_folder
  cd $tmp_init_overlay_folder
  git init .
  # define .gitignore file for overlay to be $gitignore_overlay - remap so that we can use .gitignore for git repo where overlay is done
  echo "        excludesFile=$gitignore_overlay" >> .git/config
  cd ..
  mv $tmp_init_overlay_folder/.git $overlay_folder
  rmdir $tmp_init_overlay_folder

  # ----------
  echo ""                                  > $gitignore_overlay
  echo ".gitignore"                       >> $gitignore_overlay
  echo ".git"                             >> $gitignore_overlay
  echo "$gitignore_base"                  >> $gitignore_overlay
  echo ""                                 >> $gitignore_overlay
  echo "# add user defined ignores below" >> $gitignore_overlay
  echo ""                                 >> $gitignore_overlay

  # ----------
  echo "$gitignore_overlay"                > $gitignore_base
  echo "$overlay_folder"                  >> $gitignore_base
  echo ""                                 >> $gitignore_base
  echo "# add user defined ignores below" >> $gitignore_base
  echo ""                                 >> $gitignore_base

  if [[ -e .gitignore ]]; then
    cat .gitignore >> $gitignore_base
    rm -rf .gitignore
  fi

  # ----------
  echo -e ".gitignore: $gitignore_base $gitignore_overlay" >> Makefile
  echo -e "\techo \"\\\n# AUTOMATIC GENERATED FILE - DO NOT EDIT\\\n\\\n\" > \$@" >> Makefile
  echo -e "\tcat $gitignore_base >> \$@" >> Makefile
  echo -e "\ttail -n +\`grep -n -m 1 \"add user defined ignores below\" $gitignore_overlay | cut -f1 -d:\` $gitignore_overlay | grep -v \"add user defined ignores below\" >> \$@" >> Makefile
#| sed 's,\\,,g' 

  make .gitignore

  user_name=`git config --get user.name`
  user_email=`git config --get user.email`

  $GITO config user.name $user_name
  $GITO config user.email $user_email

  $GITO add -f $gitignore_overlay
  $GITO commit -m \"init_ignores\"
  cd $cwd
elif [[ "$cmd" == "remove-all" ]]; then
  is_in_gito_repo=`$GITO rev-parse --is-inside-work-tree 2> /dev/null` || true

  if [ "$is_in_gito_repo" != "true" ]; then
    echo "ERROR: Init aborting due to not in any git overlay repository."
    exit -1
  fi

  nr_stashes=`$GITO nr-stashes`
  nr_changed_files=`$GITO nr-changed-files`
  nr_changed_files_cached=`$GITO nr-changed-files-cached`
  nr_unpushed_commits=`$GITO nr-unpushed-commits`
  nr_unpushed_files=`$GITO nr-unpushed-files`


  if [[ $nr_changed_files != "0" ]]; then
    echo "ERROR: There are local files with changes. Aborting."
    exit -1
  elif [[ $nr_changed_files_cached != "0" ]]; then
    echo "ERROR: There are cached files with changes. Aborting."
    exit -1
  elif [[ $nr_unpushed_commits != "0" ]]; then
    echo "ERROR: There are unpushed commits. Aborting."
    exit -1
  elif [[ $nr_unpushed_files != "0" ]]; then
    echo "ERROR: There are unpushed files. Aborting."
    exit -1
  elif [[ $nr_stashes != "0" ]]; then
    echo "ERROR: There are stashes. Aborting."
    exit -1
  else
    `$GITO find | xargs rm -rf`
    dot_git_path=`$GITO get-dot-git-path`
    rm -rf $dot_git_path
  fi
else
  git_root_path=`git root`
  export GIT_DIR=$git_root_path/$overlay_folder
  export GIT_WORK_TREE=$git_root_path
  git $cmd $opts
fi

