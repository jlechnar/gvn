#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

set -x
set -e

cwd=`pwd`
cwd_abs=`realpath $cwd`
user=`echo $USER`

cat run.expanded.log | sed "s,$cwd,../,g" | sed "s,$cwd_abs,../,g" | sed 's,..//,../,g' > run.reduced.log
./patch_for_compare.sh $cwd $user run.reduced.log > run.log
