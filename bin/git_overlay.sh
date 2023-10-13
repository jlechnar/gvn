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

# set -x
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

  git_root_path=`git rev-parse --show-toplevel`

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
  echo "      excludesFile=$gitignore_overlay" >> .git/config
  cd ..
  mv $tmp_init_overlay_folder/.git $overlay_folder
  rmdir $tmp_init_overlay_folder

  # ----------
  echo ".gitignore"                        > $gitignore_overlay
  echo "$gitignore_base"                  >> $gitignore_overlay
  echo ".git"                             >> $gitignore_overlay
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
else
  git_root_path=`git rev-parse --show-toplevel`
  export GIT_DIR=$git_root_path/$overlay_folder
  export GIT_WORK_TREE=$git_root_path
  git $cmd $opts
fi

