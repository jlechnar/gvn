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

setup_path "${PREFIX_EXAMPLE_PATH}_cat" "Setup cat"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user3/

######################
#execute "$GIT --no-pager lgsb" "log with svn revisions"
# execute "$GIT lgsb" "log with svn revisions"

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

# ----------------------------
echo -e '0:\nclass foo:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e '0:\nmy $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '0:\n<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > file.html

execute "$GIT add file*" "add some files"

execute "$GIT commit -a -m 'files0'" "commit new files"

echo -e '1:\nclass bar:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e '1:\nmy $test = 3;\n$test++;\nprint(\"%d\",$test5);\n' > file.pl
echo -e '1:\n<html>\n  <title>bar</title>\n  <body>\n    foo\n  </body>\n</html>' > file.html

execute "$GIT commit -a -m 'files1'" "change1"

echo -e '2:\nclass bear:\n  def foo(self, test):\n    self.test = test\n\n' > file.py
echo -e '2:\nmy $test = 4;\n$test++;\nprint(\"%d\",$test4);\n' > file.pl
echo -e '2:\n<html>\n  <title>bar</title>\n  <body>\n    food\n  </body>\n</html>' > file.html

execute "$GIT commit -a -m 'files2'" "change2"

echo -e '3:\nclass fear:\n  def for(self, test):\n    self.test = test\n\n' > file.py
echo -e '3:\nmy $test = 8;\n$test++;\nprint(\"%d\",$test2);\n' > file.pl
echo -e '3:\n<html>\n  <title>baa</title>\n  <body>\n    baer\n  </body>\n</html>' > file.html

execute "$GIT commit -a -m 'files3'" "change3"

echo -e '4:\nclass fear:\n  def while(self, test):\n    self.test = test\n\n' > file.py
echo -e '4:\nmy $test = 9;\n$test++;\nprint(\"%d\",$test12);\n' > file.pl
echo -e '4:\n<html>\n  <title>ba</title>\n  <body>\n    near\n  </body>\n</html>' > file.html

execute "$GIT add file*" "add some files"

execute "$GIT commit -a -m 'files4'" "change4"

file_pl_hash_1=`$GIT log --no-color file.pl | grep commit | awk '{print $2}' | head -n 4 | tail -n 1`
file_pl_hash_2=`$GIT log --no-color file.pl | grep commit | awk '{print $2}' | head -n 3 | tail -n 1`
file_pl_hash_3=`$GIT log --no-color file.pl | grep commit | awk '{print $2}' | head -n 2 | tail -n 1`
file_pl_hash_4=`$GIT log --no-color file.pl | grep commit | awk '{print $2}' | head -n 1 | tail -n 1`

file_html_hash_1=`$GIT log --no-color file.html | grep commit | awk '{print $2}' | head -n 4 | tail -n 1`
file_html_hash_2=`$GIT log --no-color file.html | grep commit | awk '{print $2}' | head -n 3 | tail -n 1`
file_html_hash_3=`$GIT log --no-color file.html | grep commit | awk '{print $2}' | head -n 2 | tail -n 1`
file_html_hash_4=`$GIT log --no-color file.html | grep commit | awk '{print $2}' | head -n 1 | tail -n 1`

execute "$GIT cat file.pl" "cat 0"

execute "$GIT cat $file_pl_hash_1 file.pl" "cat 1"

execute "$GIT cat $file_pl_hash_2 file.pl" "cat 2"

execute "$GIT cat $file_pl_hash_3 file.pl" "cat 3"

execute "$GIT cat $file_pl_hash_4 file.pl" "cat 4"

execute "cd test9" "cd test9"

execute "$GIT cat $file_pl_hash_4 ../file.pl" "cat 4"

execute "cd .." "cd top"

execute "$GVN wa test" "add worktree test"

execute "$CDW test" "change to worktree test"

execute "pwd" "current dir"

execute "$GIT wl" "worktrees"

execute "pwd" "current dir"

echo -e '5:\nclass fear:\n  def while(self, test1):\n    self.test2 = test3\n\n' > file.py
echo -e '5:\nmy $test = 10;\n$test++;\nprint(\"%d\",$test12);\n' > file.pl
echo -e '5:\n<html>\n  <title>barr</title>\n  <body>\n    tar\n  </body>\n</html>' > file.html

execute "$GIT add file*" "add some files"

execute "$GIT commit -a -m 'files5'" "change5"

file_pl_hash_5=`$GIT log --no-color file.pl | grep commit | awk '{print $2}' | head -n 1 | tail -n 1`

execute "cd test9" "cd test9"

execute "$GIT cat $file_pl_hash_4 ../file.pl" "cat 4"

execute "$GIT cat trunk ../file.pl" "cat trunk=4"

execute "cd ../test1/test2" "cd ../test1/test2"

execute "$GIT cat $file_pl_hash_4 ../../file.pl" "cat 4"

execute "$GIT lgasb" "show all"

execute "$GIT cat $file_pl_hash_5 ../../file.pl" "cat 5"

execute "$CDW trunk" "change to worktree trunk"

execute "cd .."

execute "$GIT cat $file_pl_hash_5 ../file.pl" "cat 5"

execute "$GIT cat test ../file.pl" "cat test=5"

execute "$GIT lgasb" "show all"
