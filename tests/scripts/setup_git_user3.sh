#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

source ./scripts/helper_functions.sh
source ./gvn_cmd.sh

setup_path "git_user3" "create local / sandbox repository for user1"
unlink scripts

REPO_PATH=`realpath ../server1/repo`

# initialize local repository
execute "$GVN clone-ns file://$REPO_PATH/trunk ." ""

$GIT config user.name "user3"
$GIT config user.email user3@domain

source ../scripts/setup_gvn.sh
