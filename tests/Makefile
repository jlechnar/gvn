SHELL := /bin/bash

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
TARGETS_LOGS+=cat
TARGETS_LOGS+=hash
TARGETS_LOGS+=merge
TARGETS_LOGS+=tag
TARGETS_LOGS+=worktree_git
TARGETS_LOGS+=worktree_git_submodule

TARGETS=
TARGETS+=$(addsuffix .log, $(TARGETS_LOGS))

TARGETS_FOLDERS=
TARGETS_FOLDERS+=$(addprefix test_, $(TARGETS_LOGS))

default: $(TARGETS)

CWD:=$(shell pwd)

always:

%.log: %.sh always
	rm -rf $@* test_$*/
	echo "export GIT=\"$(CWD)/../bin/git.sh\"" > gvn_cmd.sh
	echo "GITO=\"$(CWD)/../bin/gito\"" >> gvn_cmd.sh
	echo "export GVN=\"$(CWD)/../bin/gvn.sh\"" >> gvn_cmd.sh
	echo "GVN_BASE=\"$(CWD)/../\"" >> gvn_cmd.sh
	echo "CDW=\"source $(CWD)/../bin/cdw.sh\"" >> gvn_cmd.sh
	./$< |& tee $@.tmp
	./scripts/patch_for_compare.sh $(CWD) $(USER) $@.tmp > $@.tmp2
	./scripts/cleanup.sh $@.tmp2 > $@
	cat test_$*/.git_history >> $@.history.tmp
	./scripts/patch_for_compare.sh $(CWD) $(USER) $@.history.tmp > $@.history.tmp2
	./scripts/cleanup.sh $@.history.tmp2 > $@.history

%.log.repatch:
	mv -f $*.log $*.log.tmp_repatch
	./scripts/patch_for_compare.sh $(CWD) $(USER) $*.log.tmp_repatch > $*.log

%.log.repatch_tmp:
	mv -f $*.log $*.log.tmp_repatch_tmp
	./scripts/patch_for_compare.sh $(CWD) $(USER) $*.log.tmp > $*.log

%.log.repatch_tmp_debug:
	./scripts/patch_for_compare.sh $(CWD) $(USER) $*.log.tmp

test:
	echo "<$(CWD)>"
	echo "<$(USER)>"

view:
	less -R basic.log

clean:
	rm -rf $(TARGETS) *.log.tmp* $(TARGETS_FOLDERS)
