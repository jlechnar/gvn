#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x

source ./scripts/helper_functions.sh
source ./gvn_cmd.sh

############
setup_path "server2" "create local repository (file system repository) server2"

mkdir repo
$GIT init --bare repo
cd repo
REPO_PATH=`pwd`
cd ..
cd ..

############
setup_path "server2_create" "create local / sandbox repository"
unlink scripts

# initialize local repository
execute "$GIT clone file://$REPO_PATH ." ""

echo scripts > .gitignore
$GIT add .gitignore

$GIT config user.name "User Setup"
$GIT config user.email "user@setup"
$GIT commit -m "initial commit" .
$GIT push

cd ..
remove_path "server2_create"

