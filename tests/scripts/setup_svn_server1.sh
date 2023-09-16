#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x

source ./scripts/helper_functions.sh

############
setup_path "server1" "create local repository (file system repository) server1"

mkdir repo
svnadmin create repo
cd repo
REPO_PATH=`pwd`
cd ..
cd ..

############
setup_path "server1_create" "create local / sandbox repository"

# initialize local repository
execute "svn checkout file://$REPO_PATH ." ""

for path in "trunk branches tags"; do
  mkdir $path
  svn add $path
done

cd trunk
echo scripts > .svnignore
svn add .svnignore
cd ..

svn commit . -m "initial commit"

cd ..
remove_path "server1_create"

