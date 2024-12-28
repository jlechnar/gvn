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

setup_path "${PREFIX_EXAMPLE_PATH}_worktree" "Setup worktree"

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

######################
echo -e 'class foo23:\n  def bar23(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file.html
mkdir test_folder
echo -e '<html>\n  <title>bar bar</title>\n  <body>\n    foo foo\n  </body>\n</html>' > test_folder/file.html
echo -e 'class barbar:\n  def foofoo(self, test):\n    self.test = test\n\n' > test_folder/file.py

execute "git add file* test_folder/" "add some files"

execute "git commit -m 'files'" "commit new files"

execute "$GVN uc" "update commit to svn"

# --------------
execute "$GVN wl" "list worktrees"

execute "$GVN wa test" "add worktree test"

execute "$GVN wl" "list worktrees"

execute "test_worktree=\`$GVN wg test\`" "get worktree path for test worktree"

execute "trunk_worktree=\`$GVN wg trunk\`" "get worktree path for trunk worktree"

execute "cd $test_worktree" "change to test worktree"

execute "pwd" "show current dir"

execute "cd $trunk_worktree" "change to trunk worktree"

execute "pwd" "show current dir"

# ===============================================
execute "echo 'subtest'" "test rebase"

# --------------
execute "cd $test_worktree" "change to test worktree"

# conflict:
echo -e 'class foo234:\n  def bar234(self, test):\n    self.test = test\n\n' > file.py
# new:
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file4.pl
# merge fine
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar24\n  </body>\n</html>' > file.html

execute "git add file4.pl" "added new file"

execute "git commit -a -m 'changes_test_worktree_rebase'" "changes in test worktree rebase"

# --------------
execute "cd $trunk_worktree" "change to trunk worktree"

echo -e 'class foo235:\n  def bar235(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file5.pl
echo -e '<html>\n  <title>foo35</title>\n  <body>\n    bar2\n  </body>\n</html>' > file.html

execute "git add file5.pl" "added new file"

execute "git commit -a -m 'changes_trunk_worktree_rebase'" "changes in trunk worktree rebase"

# --------------
execute "cd $test_worktree" "change to test worktree"

set +e
# disable abort of script => known error due to merge conflict !
execute "$GVN wrebase trunk" "rebase with trunk"
set -e

echo -e 'class foo2345:\n  def bar2345(self, test):\n    self.test = test\n\n' > file.py

execute "git add file.py" "fixed rebase conflict"

execute "GIT_EDITOR=true git rebase --continue" "finish rebase after fixing conflict - using auto message / same message as before"

execute "git lgasb"

# --------------

execute "cd $trunk_worktree" "change to trunk worktree"

execute "$GVN wmerge test" "merge with test"

execute "git lgasb"

execute "$GVN uc" "update commit to svn"

execute "git lgasb"

# ===============================================
execute "echo 'subtest'" "test merge with svn update in between"

# --------------
execute "cd $test_worktree" "change to test worktree"

# conflict:
echo -e 'class foo23456:\n  def bar23456(self, test):\n    self.test = test\n\n' > file.py
# new:
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file6.pl
# merge fine
echo -e '<html>\n  <title>foo35</title>\n  <body>\n    bar246\n  </body>\n</html>' > file.html

execute "git add file6.pl" "added new file"

execute "git commit -a -m 'changes_test_worktree_merge_svn_up'" "changes in test worktree merge svn up"

# --------------
execute "cd $trunk_worktree" "change to trunk worktree"

execute "$GVN up" "git svn update"

execute "git lgasb"

# --------------
cd ..
cd git_user2/

execute "$GVN up" "git svn update"

echo -e 'class foo23458:\n  def bar23458(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file8.pl
echo -e '<html>\n  <title>foo35</title>\n  <body>\n    bar24\n  </body>\n<p>bla8</p>\n</html>' > file.html

execute "git add file8.pl" "added new file"

execute "git commit -a -m 'changes_trunk_worktree_merge_svn_change_from_other_svn_sandbox'" "changes in trunk worktree merge svn change"

execute "$GVN commit" "git svn commit from other svn sandbox"

execute "git lgasb"

# --------------
cd ..
cd git_user3/

# --------------
execute "cd $trunk_worktree" "change to trunk worktree"

echo -e 'class foo23457:\n  def bar23457(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file7.pl
echo -e '<html>\n  <title>foo357</title>\n  <body>\n    bar24\n  </body>\n</html>' > file.html

execute "git add file7.pl" "added new file"

execute "git commit -a -m 'changes_trunk_worktree_merge_svn_change'" "changes in trunk worktree merge"

execute "git lgasb"

set +e
# disable abort of script => known error due to merge conflict !
execute "$GVN up" "git svn update and so get conflict and new files from other sandbox"
set -e

echo -e 'class foo234578:\n  def bar234578(self, test):\n    self.test = test\n\n' > file.py

execute "git add file.py" "fixed gvn up conflict - set to common base"

execute "GIT_EDITOR=true git rebase --continue" "finish rebase after fixing conflict from other sandbox - using auto message / same message as before"

execute "$GVN commit" "git svn commit"

execute "git lgasb"

# --------------
execute "cd $test_worktree" "change to test worktree"

execute "git lgasb"

set +e
execute "$GVN wrebase trunk" "rebase with trunk"
set -e

echo -e 'class foo2345678:\n  def bar2345678(self, test):\n    self.test = test\n\n' > file.py

execute "git add file.py" "add changes"

execute "GIT_EDITOR=true git rebase --continue" "finish rebase"

execute "git lgasb"

# --------------
execute "cd $trunk_worktree" "change to trunk worktree"

execute "$GVN wmerge test" "merge with test"

execute "$GVN commit" "git svn commit"

execute "git lgasb"

# ---------------
cd ..
cd svn_user1/
execute "svn cp ^/trunk ^/branches/test0 -m 'created test0 branch from trunk'" "add test0 branch to svn"
cd ..
cd git_user2/
execute "$GVN up" "updated to see and get test0 branch"

execute "git bl" "show all branches"

# ---------------
# FIXXME:
execute "$GVN wa test0 origin/test0" "add worktree from existing test0 branch"

execute "$GVN wa test1" "add worktree test1 of head"

execute "$GVN wa test2 HEAD^" "add worktree test2"

execute "$GVN wa test3 test4 HEAD^" "add worktree test3 in test4 folder"

execute "$CDW test0" "change to worktree test0"

###############
# remove worktree after worktree add down to branch

show_status() {
  execute "$GVN bl" "list branches"

  execute "$GVN wl" "list worktrees"

  dot_git_abs=`git get-dot-git-path-abs`
  
  execute "ls $dot_git_abs/gvn/branch" "show contents of gvn status folder"
}

show_status
execute "$GVN wa test0a" "add worktree test0a of head"

show_status
execute "$GVN wd test0a" "delete worktree test0a"

show_status
execute "$GVN wa test0a2 test0a"  "delete worktree test0a2 from branch test0a"

show_status
execute "$GVN wd test0a2" "delete worktree test0a2"

show_status
execute "$GVN bd test0a" "remove branch test0a"

###############
show_status
execute "$GVN ba test0a" "add branch test0a"

show_status
execute "$GVN wa test0a" "add worktree test0a from existing branch"

show_status
execute "$GVN wd test0a" "delete worktree test0a"

show_status
execute "$GVN bd test0a" "remove branch test0a"

show_status
# execute "git ba test6" "add branch test6"
# 
# # execute "git bp test6 origin" "push branch test6 to origin"
# 
# execute "git bdl test6" "remove branch test6 locally"
# 
# # FIXME: how to create new remote svn branch ???
# execute "$GVN wa test6 origin/test6" "add branch test6 from remote"
# 
# execute "git ba test7" "add branch test7"
# 
# # execute "git bp test7 origin" "push branch test7 to origin"
# 
# execute "git bdl test7" "remove branch test7 locally"
# 
# execute "$GVN wa origin/test7" "add branch test7 from remote using same name for local branch"

execute "git wl" "list worktrees"

execute "git lgab" "show all branches in log"

execute "git bl" "show all branches"

################
# check functionallity of updates in a subfolder in a worktree of a branch
cd ..
cd svn_user1/
execute "svn up" "update to latest data in test0 subfolder"
echo -e '<html>\n  <title>bar bar2</title>\n  <body>\n    foo2 foo\n  </body>\n</html>' > test_folder/file.html
echo -e 'class barbarbar:\n  def foofoofoo(self, test):\n    self.test = test\n\n' > test_folder/file.py
execute "svn commit -m 'remote changes'" "commit some changes"
cd ..
cd git_user2/

execute "$CDW test0" "change to worktree test0"

execute "cd test_folder" "go into subfolder"

execute "$GVN up" "updated to see changes comming in from remote in worktree subfolder"


