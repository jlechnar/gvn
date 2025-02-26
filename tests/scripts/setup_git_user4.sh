#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

source ./scripts/helper_functions.sh
source ./gvn_cmd.sh
cwd=`pwd`
setup_path "git_user4" "create local / sandbox repository for user4"
unlink scripts

REPO_PATH=`realpath ../server2/repo`

# initialize local repository
execute "$GIT clone file://$REPO_PATH ." ""

$GIT config user.name "user4"
$GIT config user.email user4@domain
$GIT config protocol.file.allow always

# source ../scripts/setup_gvn.sh
