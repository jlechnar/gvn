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

setup_path "${PREFIX_EXAMPLE_PATH}_hash" "Setup hash"

ln -s ../gvn_cmd.sh .

./scripts/setup_svn_server1.sh
./scripts/setup_svn_user1.sh
./scripts/setup_git_user2.sh
./scripts/setup_git_user3.sh

cd git_user3/

######################
#execute "git --no-pager lgsb" "log with svn revisions"
# execute "git lgsb" "log with svn revisions"

echo -e '0:\nclass foo:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e '0:\nmy $test = 2;\n$test++;\nprint(\"%d\",$test);\n' > file.pl
echo -e '0:\n<html>\n  <title>foo</title>\n  <body>\n    bar\n  </body>\n</html>' > file.html

execute "git add file*" "add some files"

execute "git commit -a -m 'files'" "commit new files"

echo -e '1:\nclass bar:\n  def bar(self, test):\n    self.test = test\n\n' > file.py
echo -e '1:\nmy $test = 3;\n$test++;\nprint(\"%d\",$test5);\n' > file.pl
echo -e '1:\n<html>\n  <title>bar</title>\n  <body>\n    foo\n  </body>\n</html>' > file.html

execute "git commit -a -m 'files'" "change1"

echo -e '2:\nclass bear:\n  def foo(self, test):\n    self.test = test\n\n' > file.py
echo -e '2:\nmy $test = 4;\n$test++;\nprint(\"%d\",$test4);\n' > file.pl
echo -e '2:\n<html>\n  <title>bar</title>\n  <body>\n    food\n  </body>\n</html>' > file.html

execute "git commit -a -m 'files'" "change2"

echo -e '3:\nclass fear:\n  def for(self, test):\n    self.test = test\n\n' > file.py
echo -e '3:\nmy $test = 8;\n$test++;\nprint(\"%d\",$test2);\n' > file.pl
echo -e '3:\n<html>\n  <title>baa</title>\n  <body>\n    baer\n  </body>\n</html>' > file.html

execute "git commit -a -m 'files'" "change3"

echo -e '4:\nclass fear:\n  def while(self, test):\n    self.test = test\n\n' > file.py
echo -e '4:\nmy $test = 9;\n$test++;\nprint(\"%d\",$test12);\n' > file.pl
echo -e '4:\n<html>\n  <title>ba</title>\n  <body>\n    near\n  </body>\n</html>' > file.html

execute "git add file*" "add some files"

echo -e '5:\nclass fear:\n  def while(self, test1):\n    self.test2 = test3\n\n' > file.py
echo -e '5:\nmy $test = 10;\n$test++;\nprint(\"%d\",$test12);\n' > file.pl
echo -e '5:\n<html>\n  <title>barr</title>\n  <body>\n    tar\n  </body>\n</html>' > file.html

echo -e '6:\nclass fear:\n  def while(self, test5):\n    self.test2 = test3\n\n' > file_local.py
echo -e '6:\nmy $test = 13;\n$test++;\nprint(\"%d\",$test222);\n' > file_local.pl
echo -e '6:\n<html>\n  <title>arr</title>\n  <body>\n    gz\n  </body>\n</html>' > file_local.html

execute "$GVN ucs" "commit to svn"

# ----------------------------------------
execute "$GVN hash r2" "get hash for r2"

execute "$GVN hash 3" "get hash for r3"

execute "$GVN hash r1" "get hash for r1"

# ----------------------------------------
execute "$GVN lgb r2" "log for r2 revision"

execute "$GVN lgb r2:r2" "log for r2 revision only"

execute "$GVN lgb r2:2" "log for r2 revision only"

execute "$GVN lgb r2:r4" "log for r2 to r4 revision"

execute "$GVN lgb r2:4" "log for r2 to r4 revision"

set +e
execute "$GVN lgb r4:r2" "log for r2 to r4 revision"

execute "$GVN lgb r4:2" "log for r2 to r4 revision"
set -e

execute "$GVN lgb -r2:4" "log for r2 to r4 revision"

execute "$GVN lgb -r2:r4" "log for r2 to r4 revision"

set +e
execute "$GVN lgb -r4:2" "log for r2 to r4 revision"

execute "$GVN lgb -r4:r2" "log for r2 to r4 revision"
set -e

# ---------------------------------------------
execute "$GVN log r4:r2" "log for r2 to r4 revision"

execute "$GVN log r4:2" "log for r2 to r4 revision"

execute "$GVN log -r4:2" "log for r2 to r4 revision"

execute "$GVN log -r4:r2" "log for r2 to r4 revision"

