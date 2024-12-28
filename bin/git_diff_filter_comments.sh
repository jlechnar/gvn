#!/bin/sh -

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

# pipe does not work
exec sed -r 's,(#|//|%).*$,,g' -- "$@"

# nested c multiline comments are not supported by below !
#exec sed -r 's,%.*$,,g' | sed -r 's,#.*$,,g' | sed -r 's,//.*$,,' | perl -0777 -pe 's{/\*.*?\*/}{}gs' -- "$@"

