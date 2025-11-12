#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

NONE='\033[0m'

# Special Colors
#C='\033[0;2m'                  # Default color setting
#CB='\033[0;1m'                 # Default color setting and bright a little bit

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
PETROL='\033[38;5;67m'
VIOLET='\033[38;5;55m'

BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'
BOLD_PETROL='\033[38;5;67;1m'
BOLD_VIOLET='\033[38;5;55;1m'

BRIGHT_CYAN='\033[0;106m'

COLOR_RUN=$BOLD_CYAN
COLOR_USER=$BOLD_GREEN
COLOR_CWD=$BOLD_PETROL
COLOR_BRANCH=$BOLD_VIOLET
COLOR_CMD=$BOLD_RED
COLOR_H1=$BOLD_CYAN
COLOR_H1_CONTENT=$BOLD_BLUE
COLOR_H2=$BOLD_CYAN
COLOR_H2_CONTENT=$BOLD_BLUE
COLOR_H3=$BOLD_CYAN
COLOR_H3_CONTENT=$BOLD_BLUE
COLOR_CMT=$BOLD_CYAN
COLOR_CMT_CONTENT=$BOLD_MAGENTA
