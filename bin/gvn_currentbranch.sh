#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -e
#set -x

root=`$GIT root`
cwd=`pwd`

subpath=`realpath --relative-to=$root $cwd`

branch=`$GIT svn info | grep URL | sed "s,/${subpath}$,,g" | rev | sed "s,/, ,g" | $GIT awk1 | rev`

echo $branch
