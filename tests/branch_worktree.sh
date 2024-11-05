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

setup_path "${PREFIX_EXAMPLE_PATH}_branch_worktree" "Setup branch_worktree"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user2/

######################
#execute "git --no-pager lgs" "log with svn revisions"
# execute "git lgsb" "log with svn revisions"

echo -e 'class foo:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > file.html

mkdir test1
echo -e 'class foo:\n  def bar(self, test):\n    self.test = test\n\n' > test1/file1.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > test1/file1.pl
echo -e '<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > test1/file1.html

execute "git add file* test1/*" "add some files"

execute "git commit -m 'files'" "commit new files"

execute "$GVN uc" "push to svn"

execute "wt_trunk=\`$GVN wg trunk\`" "get worktree path for trunk worktree"


# trunk (svn base)
#   -> test1 (worktree)
# test (svn base)
#   -> test2 (worktree)
#      -> test3 (worktree) (failing trial)
# 
execute "$GVN wa test1" "create worktree from branch trunk to test1"

execute "$GVN branch test" "create gvn branch test"

execute "wt_test=\`$GVN wg test\`" "get worktree path for test worktree"

execute "$GVN wa test2" "create worktree from branch test to test2"

execute "wt_test2=\`$GVN wg test2\`" "get worktree path for test2 worktree"

execute "cd $wt_test2" "change to test2"

set +e
execute "$GVN wa test3" "try to create worktree in worktree not svn branch"
set -e

echo -e 'class foo2:\n  def bar(self, test):\n    self.test = test\n\n' > file.py

execute "git commit -a -m 'wt_test2_change'" "change on test2 worktree"

execute "cd $wt_test" "change to test"

set +e
execute "$GVN ws" "sync worktree failing due to missing branch name and auto detect fails"
set -e

echo -e 'my $test = 3;\n$test++;\nprint(\"%d\",$test);\n' > file.pl

execute "git commit -a -m 'wt_test_change'" "change on test worktree"

execute "cd $wt_test2" "change to test2"

execute "$GVN ws" "sync worktree from test to test2 (rebase)"

execute "cd $wt_test" "change to test"

execute "$GVN ws test2" "sync worktree from test2 to test (merge)"

set +e
execute "$GVN ws test1" "sync worktree from test1 to test (abort due to wrong base tree)"
set -e

# subfolder test
execute "cd $wt_test/test1" "change to test test1 subfolder"

execute "$GVN wa test5" "create worktree from branch test to test5"

execute "wt_test5=\`$GVN wg test5\`" "get worktree path for test5 worktree"

echo -e '<html>\n  <title>loo</title>\n  <body>\n    far\n  </body>\n</html>' > file1.html

execute "git commit -a -m 'wt_test_change'" "change on test worktree"

execute "cd $wt_test5/test1" "change to test5 test1 subfolder"

execute "$GVN ws test" "sync worktree from test to test5 (rebase)"

echo -e '<html>\n  <title>bar</title>\n  <body>\n    gar\n  </body>\n</html>' > file1.html

execute "git commit -a -m 'wt_test5_change'" "change on test5 worktree"

execute "cd $wt_test/test1" "change to test test1 subfolder"

execute "$GVN ws test5" "sync worktree from test5 to test (merge)"

# global logs
execute "cd $wt_test" "change to test"

execute "git lgasb" "log with svn revisions"

execute "cd $wt_test" "change to test"

execute "$GVN wa test4" "create worktree from branch trunk to test4"

execute "git lgasb" "log with svn revisions"

execute "$GVN wl" "list worktrees"

execute "$GVN wd test4" "delete worktree test4"

execute "git lgasb" "log with svn revisions"

execute "$GVN wl" "list worktrees"

execute "$GVN wd test2" "delete worktree test2"

execute "git lgasb" "log with svn revisions"

execute "$GVN wl" "list worktrees"
