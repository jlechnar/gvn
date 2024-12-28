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

setup_path "${PREFIX_EXAMPLE_PATH}_tag" "Setup tag"

ln -s ../gvn_cmd.sh .

./scripts/setup_git_server1.sh
./scripts/setup_git_user1.sh

cd git_user1/

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
  execute "git add $file" "add $file"
  execute "git commit $file -m \"add_$file\"" "commit $file"
done

execute "git push" "push to git repo"

# -------------------------------------
execute "pwd" "current directory"

execute "git tl origin"

execute "git ta 1.0 -m \"bla\""

execute "git tl origin"

execute "git tp 1.0 origin"

execute "git tl origin"

execute "git tm 1.0 1.1"

execute "git tl origin"

execute "git ta 2.0 HEAD^ -m \"bla 2\""
execute "git tp 2.0 origin"

execute "git ta 3.0 HEAD^^ -m \"bla 3\""
execute "git tp 3.0 origin"

execute "git ta 4.0 HEAD^^ -m \"bla 4\""
execute "git tp 4.0 origin"

execute "git ta 5.0 HEAD^ -m \"bla 5\""
execute "git tp 5.0 origin"

execute "git tdl 2.0"

execute "git tdr 3.0 origin"

execute "git td 4.0"

execute "git td 5.0 origin"

execute "git tl"

# ----------------------------
execute "git tla origin"

execute "git tla"

execute "git tl origin"

execute "git tl"

execute "git tll"

execute "git tlr origin"


