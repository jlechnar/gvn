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

setup_path "${PREFIX_EXAMPLE_PATH}_worktree_git_submodule" "Setup worktree (git submodule)"

ln -s ../gvn_cmd.sh .

./scripts/setup_git_server1.sh
./scripts/setup_git_server2.sh
./scripts/setup_git_user1.sh
./scripts/setup_git_user4.sh

######################
cd git_user1/

######################
echo -e 'class foo23:\n  def bar23(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file.html

mkdir test_folder1
cd test_folder1
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file2.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file2.html
cd ..

execute "git add file* test_folder*" "add some files"

execute "git commit -m 'files'" "commit new files"

execute "git push" "push added files"

cd ..

######################
cd git_user4/

######################
echo -e 'class foo23:\n  def bar23(self, test):\n    self.test = test\n\n' > file_sm.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file_sm.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file_sm.html

mkdir test_folder2
cd test_folder2
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file2_sm.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file2_sm.html
cd ..


execute "git add file* test_folder*" "add some files"

execute "git commit -m 'files'" "commit new files in submodule"

execute "git push" "push added files"

cd ..

######################
cd git_user1/

######################

GIT_SERVER2_REPO_PATH=`realpath ../server2/repo`

execute "git -c protocol.file.allow=always submodule add file://$GIT_SERVER2_REPO_PATH sm" "add submodule in subfolder sm"

execute "git add .gitmodules sm" "add submodule"

execute "git commit -m 'submodule'" "commit submodule connection"

execute "git push" "push added submodule"

######################
execute "git wa test1" "add worktree test1"

######################
echo -e 'my $test = 3;\n$test++;\nprint(\"%d\",$test);\n' > test_folder1/file2.pl
echo -e 'my $test = 4;\n$test++;\nprint(\"%d\",$test);\n' > sm/file_sm.pl
echo -e 'my $test = 5;\n$test++;\nprint(\"%d\",$test);\n' > sm/test_folder2/file2_sm.pl

######################
execute "$CDW test1" "change to worktree test1"

execute "git -c protocol.file.allow=always submodule-init-recursive" "init submodule"

######################
echo -e 'my $test = 6;\n$test++;\nprint(\"%d\",$test);\n' > test_folder1/file2.pl
echo -e 'my $test = 7;\n$test++;\nprint(\"%d\",$test);\n' > sm/file_sm.pl
echo -e 'my $test = 8;\n$test++;\nprint(\"%d\",$test);\n' > sm/test_folder2/file2_sm.pl

######################
folders="sm/
sm/test_folder2/
test_folder1/"

cmds_git="d
dw"

do_check () {
  for folder in $folders; do
    cwd=`pwd`
    cd $folder
    execute "pwd" "current directory"
    for cmd_git in $cmds_git; do
      execute "git $cmd_git" "diff all"
      execute "git $cmd_git ." "diff local"
    done
    cd $cwd
    for cmd_git in $cmds_git; do
      execute "git $cmd_git $folder" "diff folder"
    done
  done
}

######################
do_check

######################
execute "$CDW master" "change to worktree master"

######################
do_check

