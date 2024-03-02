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

setup_path "${PREFIX_EXAMPLE_PATH}_merge" "Setup merge"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user2/

######################
#execute "git --no-pager lgs" "log with svn revisions"
execute "git lgsb" "log with svn revisions"

######################
# setup files and commit them to svn

echo -e 'class foo23:\n  def bar23(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file.html

execute "git add file*" "add some files"

execute "git commit -m 'files'" "commit new files"

execute "$GVN uc" "update commit to svn"

######################
cd ../git_user3

execute "$GVN up" "update from svn"

######################
cd ../svn_user1

execute "svn update " "update"

echo -e 'class foo234:\n  def bar234(self, test):\n    self.test = test\n\n' > file.py

execute "svn commit -m 'changes' " "changes"

######################
cd ../git_user2

echo -e 'class foo123:\n  def bar123(self, test):\n    self.test = test\n\n' > file.py

execute "git st" "show status"

execute "git commit -a -m 'conflicting_changes'" "conflicting changes"

set +e
# disable abort of script => known error due to merge conflict !
execute "$GVN update" "generate local conflict"
set -e

execute "git st" "show status"

cmd_git="merge-file-diff
mfd"

for cmd2 in $cmd_git; do
  execute "git $cmd2 file.py" "generate diff files"
  execute "cat file.py.MR_BASE" "show generated files"
  execute "cat file.py.MR_THEIRS" "show generated files"
  execute "cat file.py.MR_OURS" "show generated files"
done

cmd_git="merge-diff
md
merge-diff-ours
mdo
merge-diff-theirs
mdt
merge-diff-base
mdb
merge-diff-wordwise
mdw
merge-diff-wordwise-ours
mdwo
merge-diff-wordwise-theirs
mdwt
merge-diff-wordwise-base
mdwb"

for cmd2 in $cmd_git; do
  execute "git $cmd2 file.py" "show merge diff"
done

cmd_git="merge-file-ours
mfo
merge-file-theirs
mft
merge-file-base
mfb
merge-file-merge
mfm"

for cmd2 in $cmd_git; do
  execute "git $cmd2 file.py" "checkout fixed solution"
  execute "cat file.py" "show contents of file"
done

###################
execute "git rebase --abort" "abort merge"

execute "git st" "show status"

execute "git lgsb" "log with svn revisions"

