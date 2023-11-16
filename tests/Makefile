# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

TARGETS_LOGS=
TARGETS_LOGS+=basic
TARGETS_LOGS+=blame
TARGETS_LOGS+=worktree
TARGETS_LOGS+=overlay
TARGETS_LOGS+=backup
TARGETS_LOGS+=branch
TARGETS_LOGS+=branch_worktree
TARGETS_LOGS+=update_map_db
TARGETS_LOGS+=diff

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
	./scripts/patch_for_compare.sh $(CWD) $(CWD_REAL) $(USER) $@.tmp > $@

test:
	echo $(CWD)
	echo $(CWD_REAL)
	echo $(USER)

view:
	less -R basic.log

clean:
	rm -rf $(TARGETS) *.log.tmp
