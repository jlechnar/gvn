# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

TARGETS_LOGS=
TARGETS_LOGS+=basic
TARGETS_LOGS+=blame
TARGETS_LOGS+=worktree
TARGETS_LOGS+=overlay

TARGETS=
TARGETS+=$(addsuffix .log, $(TARGETS_LOGS))

default: $(TARGETS)

CWD:=$(shell pwd)
#CWD:=$(shell pwd | xargs realpath)
CWD_REAL = ${PWD}

always:

%.log: %.sh always
	echo "GITO=\"$(CWD)/../bin/gito\"" > gvn_cmd.sh
	echo "GVN=\"$(CWD)/../bin/gvn.sh\"" >> gvn_cmd.sh
	echo "GVN_BASE=\"$(CWD)/../\"" >> gvn_cmd.sh
	echo "GVN_BLAME=\"$(CWD)/../bin/gvn_blame.py\"" >> gvn_cmd.sh
	echo "GVN_ANNOTATE=\"$(CWD)/../bin/gvn_annotate.py\"" >> gvn_cmd.sh
	./$< | tee $@.tmp
	cat $@.tmp | sed "s,$(CWD),\.\.\.,g" | sed "s,$(CWD_REAL),\.\.\.,g" | sed "s,$(USER),<user>,g" | sed 's,[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}_[0-9]\{2\}_[0-9]\{2\},<DATE_TIME>,g' | sed 's,[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\},<TIME>,g' | sed 's,[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\},<DATE>,g' | sed 's,[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{4\},<DATE>,g' | perl -pe 's/^(r\d+\s+=\s+)[a-zA-Z0-9]+(\s+)/$$1<HASH>$$2/g' | perl -pe 's/(\e\[[0-9;]*m\s+)[0-9a-fA-F]+(\e\[[0-9;]*m\s+\e\[[0-9;]*m\s*r\d+\s*\e\[[0-9;]*m\s+)/$$1<HASH>$$2/g' | perl -pe 's/(\e\[[0-9;]*m\s*)[0-9a-fA-F]+(\e\[[0-9;]*m\s+\e\[[0-9;]*m\s*r\d+\s*\e\[[0-9;]*m\s+)/$$1<HASH>$$2/g' > $@

test:
	echo $(CWD)
	echo $(CWD_REAL)
	echo $(USER)

view:
	less -R basic.log

clean:
	rm -rf $(TARGETS)
