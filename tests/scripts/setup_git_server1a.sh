#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# set -x

source ./scripts/helper_functions.sh
source ./gvn_cmd.sh

############
setup_path "server1a" "create local repository (file system repository) server1a"

mkdir repo
$GIT init --bare repo
cd repo
REPO_PATH=`pwd`
REPO2_PATH=`echo $REPO_PATH | sed 's,server1a,server1,g'`
cd ..
cd ..

############
setup_path "server1_create" "create local / sandbox repository"
unlink scripts

# initialize local repository
execute "$GIT clone file://$REPO2_PATH ." ""
$GIT push

cd ..
remove_path "server1_create"

