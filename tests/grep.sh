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

setup_path "${PREFIX_EXAMPLE_PATH}_grep" "Setup grep"

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
echo -e "1 bla bla\nfoo bar\nbar foo " > test1/test2/test3/test4/file.a
echo -e "2 bla bla\nfoo bar\nbar foo " > test1/test2/test3/test4/file.b
echo -e "3 bla bla\nfoo bar\nbar foo " > test1/test2/test3/file.c
echo -e "4 bla bla\nfoo bar\nbar foo " > test1/test2/file.d
echo -e "5 bla bla\nfoo bar\nbar foo " > test1/file.e
echo -e "6 bla bla\nfoo bar\nbar foo " > test1/foo.bar

mkdir -p test5/test6/test7/test8
mkdir -p test5/test6/file
echo -e "1 bla bla\nfoo bar\nbar foo " > test5/test6/test7/test8/file.f
echo -e "2 bla bla\nfoo bar\nbar foo " > test5/test6/test7/file.g
echo -e "3 bla bla\nfoo bar\nbar foo " > test5/test6/file.h
echo -e "4 bla bla\nfoo bar\nbar foo " > test5/file.i
echo -e "5 bla bla\nfoo bar\nbar foo " > test5/test6/file/bar

mkdir -p test9/
echo -e "1 bla bla\nfoo bar\nbar foo " > test9/afile
echo -e "2 bla bla\nfoo bar\nbar foo " > test9/bfile
echo -e "3 bla bla\nfoo bar\nbar foo " > test9/c.file
echo -e "4 bla bla\nfoo bar\nbar foo " > test9/d.file
echo -e "5 bla bla\nfoo bar\nbar foo " > test9/foo

execute "$GIT add test1" "add some files in folders"

execute "$GIT add test5" "add some files in folders"

execute "$GIT add test9" "add some files in folders"

execute "$GIT commit -a -m 'test_folders_with_files'" "more files"

# -------------------------------------
execute "pwd" "current directory"

execute "$GIT grep 1 test5/" "grep for 1 in subdir test5"

execute "$GIT grep 1" "grep for 1 in local dir"

# -------------------------------------
execute "cd test5/" "cd test5"

execute "pwd" "current directory"

execute "$GIT grep 1" "grep for 1 within local subdir"

execute "$GIT grep-nc 1" "grep for 1 within local subdir"

execute "$GIT grep 1 test6/" "find all test6"

execute "$GIT grep-all 1" "find all 1 in all folders"

execute "$GIT grep-all-nc 1" "find all 1 in all folders no color"

execute "$GIT grep 1 ." "find all 1 in current subfolder"

execute "$GIT grep 1 ../" "grep for 1 one up"

execute "$GIT grep 1 ../test1/test2" "find all 1 in test1/test2 subfolder"

execute "$GIT grep-nc 1 ../test1/test2" "find all 1 in test1/test2 subfolder"

# -----------------------------
execute "cd test6/" "cd test6"

execute "pwd" "current directory"

execute "$GIT grep 1" "grep 1 no args"

execute "$GIT grep 1 ." "grep 1 current"

execute "$GIT grep 1 ../" "grep 1 one up"

execute "$GIT grep 1 ../.." "grep 1 two up"

execute "$GIT grep 1 ../../test1/test2/test3" "grep 1 test1 subfolder"

# -----------------------------
set +e
execute "$GIT grep 1 ../../../outside/dir" "grep 1 outside dir none existing"

execute "$GIT grep 1 ../../../git_user2" "grep 1 outside dir existing"

execute "$GIT grep 1 inside/none_existing/dir" "grep 1 none existing dir"

execute "$GIT grep 1 inside_none_existing_dir" "grep 1 none existing dir"

set -e

# -----------------------------
execute "cd ../../test9/" "go to test9"

execute "$GIT grep 1 ." "grep 1 in current"

execute "$GIT grep-nc 1 ." "grep 1 in current"

execute "$GIT grep 1" "grep 1 in current"

execute "$GIT grep-nc 1" "grep 1 in current"

# --------------
execute "$GVN wa test" "add worktree test"

execute "$GVN wl" "list worktrees"

execute "$CDW test" "change to worktree test"

# -----------------------------
execute "cd ../test5/test6/" "cd test6"

execute "pwd" "current directory"

execute "$GIT grep 1" "grep 1 no args"

execute "$GIT grep 1 ." "grep 1 current"

execute "$GIT grep 1 ../" "grep 1 one up"

execute "$GIT grep 1 ../.." "grep 1 two up"

execute "$GIT grep 1 ../../test1/test2/test3" "grep 1 test1 subfolder"

# -----------------------------
execute "cd ../../test9/" "go to test9"

execute "$GIT grep 1 ." "grep 1 in current"

execute "$GIT grep-nc 1 ." "grep 1 in current"

execute "$GIT grep 1" "grep 1 in current"

execute "$GIT grep-nc 1" "grep 1 in current"


