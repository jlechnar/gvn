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

setup_path "${PREFIX_EXAMPLE_PATH}_worktree_git" "Setup worktree (git)"

ln -s ../gvn_cmd.sh .

./scripts/setup_git_server1.sh
./scripts/setup_git_user1.sh

cd git_user1/

######################
echo -e 'class foo23:\n  def bar23(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo3</title>\n  <body>\n    bar2\n  </body>\n</html>' > file.html

execute "git add file*" "add some files"

execute "git commit -m 'files'" "commit new files"

execute "git wa test1" "add worktree test1 of head"

execute "git wa test2 HEAD^" "add worktree test2"

execute "git wa test3 test4 HEAD^" "add worktree test3 in test4 folder"

execute "git ba test5" "add branch test5"

execute "git wa test5" "add worktree test5 from existing branch"

execute "git wl" "list worktrees"

execute "git lgab" "show all branches in log"

execute "git bl" "show all branches"

######################
execute "git ba test6" "add branch test6"

execute "git bp test6 origin" "push branch test6 to origin"

execute "git bdl test6" "remove branch test6 locally"

execute "git wa test6 origin/test6" "add branch test6 from remote"

execute "git ba test7" "add branch test7"

execute "git bp test7 origin" "push branch test7 to origin"

execute "git bdl test7" "remove branch test7 locally"

execute "git wa origin/test7" "add branch test7 from remote using same name for local branch"

execute "git wl" "list worktrees"

execute "git lgab" "show all branches in log"

execute "git bl" "show all branches"


