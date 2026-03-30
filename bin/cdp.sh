#!/bin/sh

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

cat ~/cdp.txt | egrep "^$1\s+" | awk '{for (i=2; i<=NF; i++) print $i}'

# add alias:
# alias cdp 'set CDP_DIR=`~/bin/cdp.sh \!*`; cd $CDP_DIR'

# create ~/cdp.txt with content:
# b ~/bin
# p ~/project
# etc.
