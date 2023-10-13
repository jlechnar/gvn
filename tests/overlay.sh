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

setup_path "${PREFIX_EXAMPLE_PATH}_overlay" "Setup overlay"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user3/

# -----------------------------------------
execute "$GITO init" "init git overlay"

execute "$GITO status" "status git overlay"

echo -e 'class foo:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > file.html

echo "ignore me for normal usage" > overlay1.txt

execute "$GITO add overlay1.txt" "add file to ignore in overlay"

execute "$GITO commit -m 'add_ignore'" "commit file to ignore in overlay"

execute "$GITO status" "show status"

execute "$GITO lgab" "show history"

execute "git add -f .gitignore .gitignore_base" "add ignores"

execute "git commit -m 'add_gitignore'" "add gitignor files"

execute "git status" "show status"

execute "git lgasb" "show history"

execute "echo \"overlay1.txt\" >> .gitignore_overlay" "add new file to ignores"

execute "make .gitignore" "update .gitignore"

execute "git status" "show status"

execute "git lgasb" "show history"


