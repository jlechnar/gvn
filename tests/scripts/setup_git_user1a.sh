#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e

source ./scripts/helper_functions.sh
source ./gvn_cmd.sh
cwd=`pwd`

cd git_user1/

REPO_PATH=`realpath ../server1a/repo`

# initialize local repository
execute "$GIT remote add origin1a file://$REPO_PATH" "Add remote origin1a"
