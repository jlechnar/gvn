#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x

source ./scripts/helper_functions.sh

setup_path "svn_user2" "create local / sandbox repository for user1"

REPO_PATH=`realpath ../server1/repo`

# initialize local repository
execute "svn checkout file://$REPO_PATH/trunk ." ""


