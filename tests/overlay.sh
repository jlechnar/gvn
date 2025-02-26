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
./scripts/setup_git_overlay.sh

cd git_user3/

# -----------------------------------------
execute "$GITO init" "init $GIT overlay"

execute "$GITO status" "status $GIT overlay"

echo -e 'class foo:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e 'my $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > file.html

echo "ignore me for normal usage" > overlay1.txt

execute "$GITO add overlay1.txt" "add file to ignore in overlay"

execute "$GITO commit -m 'add_ignore'" "commit file to ignore in overlay"

execute "$GITO status" "show status"

execute "$GITO lgab" "show history"

execute "$GIT add -f .gitignore .gitignore_base" "add ignores"

execute "$GIT commit -m 'add_gitignore'" "add gitignor files"

execute "$GIT status" "show status"

execute "$GIT lgasb" "show history"

execute "echo \"overlay1.txt\" >> .gitignore_overlay" "add new file to ignores"

execute "make .gitignore" "update .gitignore"

execute "$GIT status" "show status"

execute "$GIT lgasb" "show history"

overlay_repo=`realpath ../git_overlay/`
execute "$GITO remote add origin $overlay_repo" "add bare overlay repo"

execute "$GITO push --set-upstream origin master" "setup master push to overaly repo"

set +e
execute "$GITO remove-all" "try to remove with uncommited change"
set -e

execute "$GITO add -u" "add all changes to cache"

set +e
execute "$GITO remove-all" "try to remove with cached changes"
set -e

execute "$GITO commit -m 'changes'" "commit all changes"

set +e
execute "$GITO remove-all" "try to remove with unpushed change"
set -e

execute "$GITO push" "push changes"

execute "$GITO remove-all" "remove gito from local folder"

