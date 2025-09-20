#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

prompt () {
  cmd=$@
  cwd=`pwd`
  if [[ $in_sandbox == "1" ]]; then
    is_empty_git_repo=`git rev-list -n 1 --all`
    if [ "$is_empty_git_repo" != "" ]; then
      cb=`git rev-parse --abbrev-ref HEAD`
    else
      cb="EMPTY"
    fi
    cb="[$cb]"
  else
    cb=""
  fi
  echo -e "${COLOR_RUN}RUN:${NONE} ${COLOR_USER}$user${NONE} @ ${COLOR_CWD}$cwd${NONE} ${COLOR_BRANCH}$cb${NONE} \$ ${COLOR_CMD}$cmd${NONE}"
}

run () {
  cmd=$@
#  set -f
  set -o noglob
  prompt $cmd
  set +o noglob
  #set +f
  eval $cmd
}

h1 () {
  t=$1
  echo ""
  echo -e "${COLOR_H1}H1 : $NONE ${COLOR_H1_CONTENT}.====================================================================================${NONE}"
  echo -e "${COLOR_H1}H1 : $NONE ${COLOR_H1_CONTENT}| $t${NONE}"
  echo -e "${COLOR_H1}H1 : $NONE ${COLOR_H1_CONTENT}'====================================================================================${NONE}"
  echo ""
}

h2 () {
  t=$1
  echo ""
  echo -e "${COLOR_H2}H2 : $NONE ${COLOR_H2_CONTENT}.-----------------------------------------------${NONE}"
  echo -e "${COLOR_H2}H2 : $NONE ${COLOR_H2_CONTENT}| $t${NONE}"
  echo -e "${COLOR_H2}H2 : $NONE ${COLOR_H2_CONTENT}'-----------------------------------------------${NONE}"
  echo ""
}

h3 () {
  t=$1
  echo ""
  echo -e "${COLOR_H3}H3 : $NONE ${COLOR_H3_CONTENT}.-----------------------------${NONE}"
  echo -e "${COLOR_H3}H3 : $NONE ${COLOR_H3_CONTENT}| $t${NONE}"
  echo -e "${COLOR_H3}H3 : $NONE ${COLOR_H3_CONTENT}'-----------------------------${NONE}"
  echo ""
}

cmt () {
  c=$1
  echo -e "${COLOR_CMT}CMT:$NONE ${COLOR_CMT_CONTENT}$c${NONE}"
}

waitforenter () {
  read -p "Press Enter to continue" </dev/tty
}
