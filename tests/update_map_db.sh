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

setup_path "${PREFIX_EXAMPLE_PATH}_update_map_db" "Setup update_map_db"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user3/

######################
#execute "git --no-pager lgsb" "log with svn revisions"
# execute "git lgsb" "log with svn revisions"

echo -e 'class foo:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > file.html

execute "git add file*" "add some files"

execute "git commit -m 'files'" "commit new files"

execute "$GVN uc" "update commit to svn"

execute "$GVN umdb"

execute "$GVN lgsb" "log with svn revisions"

execute "$GVN blame file.html" "Blame html no syntax highlight"

