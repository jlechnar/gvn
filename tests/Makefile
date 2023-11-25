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
TARGETS_LOGS+=worktree_cdw
TARGETS_LOGS+=ls
TARGETS_LOGS+=lsa
TARGETS_LOGS+=find
TARGETS_LOGS+=grep
TARGETS_LOGS+=log

TARGETS=
TARGETS+=$(addsuffix .log, $(TARGETS_LOGS))

TARGETS_FOLDERS=
TARGETS_FOLDERS+=$(addprefix test_, $(TARGETS_LOGS))

default: $(TARGETS)

CWD:=$(shell pwd)
#CWD:=$(shell pwd | xargs realpath)
CWD_REAL = ${PWD}

always:

%.log: %.sh always
	echo "GITO=\"$(CWD)/../bin/gito\"" > gvn_cmd.sh
	echo "GVN=\"$(CWD)/../bin/gvn.sh\"" >> gvn_cmd.sh
	echo "GVN_BASE=\"$(CWD)/../\"" >> gvn_cmd.sh
	echo "CDW=\"$(CWD)/../bin/cdw.sh\"" >> gvn_cmd.sh
	./$< | tee $@.tmp
	./scripts/patch_for_compare.sh $(CWD) $(CWD_REAL) $(USER) $@.tmp > $@.tmp2
	./scripts/cleanup.sh $@.tmp2 > $@

%.log.repatch:
	mv -f $*.log $*.log.tmp_repatch
	./scripts/patch_for_compare.sh $(CWD) $(CWD_REAL) $(USER) $*.log.tmp_repatch > $*.log

test:
	echo $(CWD)
	echo $(CWD_REAL)
	echo $(USER)

view:
	less -R basic.log

clean:
	rm -rf $(TARGETS) *.log.tmp* $(TARGETS_FOLDERS)
