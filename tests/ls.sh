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

setup_path "${PREFIX_EXAMPLE_PATH}_ls" "Setup ls"

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
echo "6" > test1/foo.bar

mkdir -p test5/test6/test7/test8
mkdir -p test5/test6/file
echo "1" > test5/test6/test7/test8/file.f
echo "2" > test5/test6/test7/file.g
echo "3" > test5/test6/file.h
echo "4" > test5/file.i
echo "5" > test5/test6/file/bar

mkdir -p test9/
echo "1" > test9/afile
echo "2" > test9/bfile
echo "3" > test9/c.file
echo "4" > test9/d.file
echo "5" > test9/foo

execute "$GIT add test1" "add some files in folders"

execute "$GIT add test5" "add some files in folders"

execute "$GIT add test9" "add some files in folders"

execute "$GIT commit -a -m 'test_folders_with_files'" "more files"

# -------------------------------------
execute "pwd" "current directory"

execute "$GIT ls test5/" "ls test5"

execute "$GIT ls" "ls no args"

# -------------------------------------
execute "cd test5/" "cd test5"

execute "pwd" "current directory"

execute "$GIT ls" "ls no args"

execute "$GIT ls test6/" "ls test6"

execute "$GIT ls ." "ls current"

execute "$GIT ls ../" "ls one up"

execute "$GIT ls ../test1/test2" "ls test1 subfolder"

# -----------------------------
execute "cd test6/" "cd test6"

execute "pwd" "current directory"

execute "$GIT ls" "ls no args"

execute "$GIT ls ." "ls current"

execute "$GIT ls ../" "ls one up"

execute "$GIT ls ../.." "ls two up"

execute "$GIT ls ../../test1/test2/test3" "ls test1 subfolder"

# -----------------------------
set +e
execute "$GIT ls ../../../outside/dir" "ls outside dir none existing"

execute "$GIT ls ../../../git_user2" "ls outside dir existing"

execute "$GIT ls inside/none_existing/dir" "ls none existing dir"

execute "$GIT ls inside_none_existing_dir" "ls none existing dir"

set -e

# -----------------------------
execute "cd ../../test9/" "go to test9"

execute "$GIT ls" "ls current"

execute "$GIT ls ." "ls current"

# --------------
execute "$GVN wa test" "add worktree test"

execute "$GVN wl" "list worktrees"

execute "$CDW test" "change to worktree test"

# -----------------------------
execute "cd ../test5/test6/" "cd test6"

execute "pwd" "current directory"

execute "$GIT ls" "ls no args"

execute "$GIT ls ." "ls current"

execute "$GIT ls ../" "ls one up"

execute "$GIT ls ../.." "ls two up"

execute "$GIT ls ../../test1/test2/test3" "ls test1 subfolder"

# -----------------------------
execute "cd ../../test9/" "go to test9"

execute "$GIT ls" "ls current"

execute "$GIT ls ." "ls current"

