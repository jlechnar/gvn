#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

source ./scripts/helper_functions.sh
source ./gvn_cmd.sh
cwd=`pwd`
setup_path "git_user1" "create local / sandbox repository for user1"
unlink scripts

REPO_PATH=`realpath ../server1/repo`

# initialize local repository
execute "git clone file://$REPO_PATH ." ""

git config user.name "user1"
git config user.email user1@domain

# source ../scripts/setup_gvn.sh