#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x
set -e

source ./scripts/setup.sh
source ./scripts/helper_functions.sh
source ./gvn_cmd.sh

setup_path "${PREFIX_EXAMPLE_PATH}_worktree_cdw" "Setup worktree_cdw"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user2/

execute "$GVN uc" "update commit to svn"

cd ..

cd git_user3/

execute "$GVN uc" "update commit to svn"

# -----------------------------------------------
mkdir -p test1/test2/test3/test4
echo "1" > test1/test2/test3/test4/file.a
echo "2" > test1/test2/test3/test4/file.b
echo "3" > test1/test2/test3/file.c
echo "4" > test1/test2/file.d
echo "5" > test1/file.e

mkdir -p test5/test6/test7/test8
echo "2" > test5/test6/test7/test8/file.f
echo "3" > test5/test6/test7/file.g
echo "4" > test5/test6/file.h
echo "5" > test5/file.i

execute "$GIT add test1" "add some files in folders"

execute "$GIT add test5" "add some files in folders"

execute "$GIT commit -a -m 'test_folders_with_files'" "more files"

execute "$GVN wl" "list worktrees"

execute "$GVN wa worktree1" "add worktree worktree1"

execute "$GVN wa worktree2" "add worktree worktree2"

execute "$GVN wl" "list worktrees"

execute "pwd" "current directory"

execute "tree" "tree of current directory"

execute "$CDW worktree1" "change to worktree test1"

execute "pwd" "current directory"

execute "$CDW worktree2" "change to worktree test2"

execute "pwd" "current directory"

execute "$CDW trunk" "change to worktree trunk"

execute "pwd" "current directory"

execute "cd test1" "change into sub directory"

execute "pwd" "current directory"

execute "$CDW worktree2" "change to worktree test2"

execute "pwd" "current directory"

execute "cd test2" "change into sub directory"

execute "pwd" "current directory"

execute "$CDW worktree1" "change to worktree test1"

execute "pwd" "current directory"

execute "cd ../../test5/test6/test7" "change into sub directory"

execute "$GIT lgb ../../file.i" "show log of file with relative path"

execute "pwd" "current directory"

execute "$CDW trunk" "change to worktree trunk"

execute "pwd" "current directory"

execute "$GIT lgb ../../file.i" "show log of file with relative path"

execute "cd ../../" "change into base directory test5"

execute "$GIT lgb file.i" "show log of file"

execute "$GVN lgb file.i" "show log of file with svn revisions"


