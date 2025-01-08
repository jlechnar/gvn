#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x

source ./scripts/helper_functions.sh

############
setup_path "server2" "create local repository (file system repository) server2"

mkdir repo
git init --bare repo
cd repo
REPO_PATH=`pwd`
cd ..
cd ..

############
setup_path "server2_create" "create local / sandbox repository"
unlink scripts

# initialize local repository
execute "git clone file://$REPO_PATH ." ""

echo scripts > .gitignore
git add .gitignore

git config user.name "User Setup"
git config user.email "user@setup"
git commit . -m "initial commit"
git push

cd ..
remove_path "server2_create"

