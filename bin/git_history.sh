#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

if [[ "$GVN_DEBUG" == "1" ]]; then
  set -x
fi
set -e

HISTORY_FILE=~/.git_history

if [[ "$#" == "1" ]]; then
  grep_for="$1"
  cat $HISTORY_FILE | egrep $grep_for
else
  cat $HISTORY_FILE
fi


