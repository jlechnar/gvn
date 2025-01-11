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

setup_path "${PREFIX_EXAMPLE_PATH}_log" "Setup log"

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

for file in `find test1/ test5/ test9/ -type f | sort`; do
  execute "$GIT add $file" "add $file"
  execute "$GIT commit $file -m \"add_$file\"" "commit $file"
done

execute "$GVN uc" "push to svn"

# -------------------------------------
execute "pwd" "current directory"

cmd_git="lb
lbf
lgb
lgbf
lgbl
lgblf"

cmd_gvn="lb
lbf
lgb
lgfb
lglb
lglfb"

for cmd2 in $cmd_git; do
  execute "$GIT $cmd2" "$cmd2"
  execute "$GIT $cmd2 test9" "$cmd2"
done

for cmd2 in $cmd_gvn; do
  execute "$GVN $cmd2" "$cmd2"
  execute "$GVN $cmd2 test9" "$cmd2"
done

cd test1

execute "pwd" "current directory"

for cmd2 in $cmd_git; do
  execute "$GIT $cmd2" "$cmd2"
  execute "$GIT $cmd2 ." "$cmd2"
  execute "$GIT $cmd2 test2" "$cmd2"
  execute "$GIT $cmd2 ../" "$cmd2"
  execute "$GIT $cmd2 ../test5" "$cmd2"
done

for cmd2 in $cmd_gvn; do
  execute "$GVN $cmd2" "$cmd2"
  execute "$GVN $cmd2 ." "$cmd2"
  execute "$GVN $cmd2 ../test9" "$cmd2"
  execute "$GVN $cmd2 ../" "$cmd2"
  execute "$GVN $cmd2 ../test5" "$cmd2"
done

# ----------------------------------
cd ..

cmd_git="lab
labf
lgab
lgabf
lgabl
lgablf"

cmd_gvn="lab
laf
lgab
lgafb
lgalb
lgalfb"

for cmd2 in $cmd_git; do
  execute "$GIT $cmd2" "$cmd2"
  execute "$GIT $cmd2 test9" "$cmd2"
done

for cmd2 in $cmd_gvn; do
  execute "$GVN $cmd2" "$cmd2"
  execute "$GVN $cmd2 test9" "$cmd2"
done

cd test1

execute "pwd" "current directory"

for cmd2 in $cmd_git; do
  execute "$GIT $cmd2" "$cmd2"
  execute "$GIT $cmd2 test2" "$cmd2"
done

for cmd2 in $cmd_gvn; do
  execute "$GVN $cmd2" "$cmd2"
  execute "$GVN $cmd2 ../test9" "$cmd2"
done

