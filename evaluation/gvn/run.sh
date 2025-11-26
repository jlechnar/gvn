#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

#set -x
set -e

exec &> >(tee -a "run.expanded.log")

source "color.sh"
source "functions.sh"

user="none"
folder="test"
in_sandbox=0

#####################################################################
h1 "used git version"
run "git --version"

#####################################################################
h1 "used svn version"
run "svn --version"

#####################################################################
h1 "create environment"
run "rm -rf $folder"
run "mkdir $folder"
run "cd $folder"

#####################################################################
h1 "create svn filesystem repository"
run "mkdir svn_repo"
run "cd svn_repo"
svn_repo=`pwd`
run "svnadmin create ."
run "tree -a"

#####################################################################
user="user1.svn"
user1_svn_sb1="user1_svn_sb1"
h1 "create svn sandbox for $user"
run "cd .."
run "mkdir $user1_svn_sb1"
run "cd $user1_svn_sb1"
run "svn checkout file://$svn_repo ."
run "tree -a"

#####################################################################
h1 "creating structures and adding contents"
cmt "project structures can vary. Common examples are single folder projects, basic trunk/branches/tags, projects-as-branch-siblings, etc."
cmt "see https://svnbook.red-bean.com/en/1.7/svn.reposadmin.planning.html"
projects="project1
project2
project3"

for p in $projects; do
  run "mkdir -p layout1/$p"
  run "cp -R ../../data/* layout1/$p"

  run "mkdir -p layout2/trunk/$p layout2/branches/$p layout2/tags/$p"
  run "cp -R ../../data/* layout2/trunk/$p"

  run "mkdir -p layout3/$p/trunk    layout3/$p/branches layout3/$p/tags"
  run "cp -R ../../data/* layout3/$p/trunk"
done

run "tree"

run "find . -type d | grep -v '^.$' | grep -v svn | sort | xargs svn add --depth=empty"
run "svn commit --username $user -m 'folder structure (initial commit)'"

run "find -name shared.gitconfig | sort | xargs svn add"
run "svn commit --username $user -m 'added shared config'"

run "find -name patch.pl | sort | xargs svn add"
run "svn commit --username $user -m 'added patch.pl required for shared config'"

run "find -name readme.txt | sort | xargs svn add"
run "svn commit --username $user -m 'added readme'"

run "find -type f -name full* | sort | xargs svn add"
run "svn commit --username $user -m 'added full adder'"

run "find -type f -name halve* | sort | xargs svn add"
run "svn commit --username $user -m 'added halve adder'"

run "find -type f -name carry* | sort | xargs svn add"
run "svn commit --username $user -m 'added carry adder'"

run "find -type l | sort | xargs svn add"
run "svn commit --username $user -m 'added links'"

#####################################################################
h1 "git svn clone"
cmt "cloning might take a long time in case of lots of svn revisions"
cmt "in such cases the number of revisions can be limited to a start revision up to the HEAD revision"
cmt "add the option '-r<svn_start_revision>:HEAD' to git svn clone"

#####################################################################
project="project1"
h2 "git svn clone from layout1 for project1"
user="user1.git_svn"
user1_git_svn_sb1="user1_git_svn_sb1"
run "cd .."
run "mkdir $user1_git_svn_sb1"
run "cd $user1_git_svn_sb1"
run "git svn clone file://$svn_repo/layout1/project1 ."
run "tree -a"
run "cat .git/config"

#####################################################################
h2 "git svn clone from layout2 for project1"
user="user1.git_svn"
user1_git_svn_sb2="user1_git_svn_sb2"
run "cd .."
run "mkdir $user1_git_svn_sb2"
run "cd $user1_git_svn_sb2"
run "git svn clone file://$svn_repo --trunk layout2/trunk/project1 --branches layout2/branches/project1 --tags layout2/tags/project1 ."
run "tree -a"
run "cat .git/config"

#####################################################################
h2 "git svn clone from layout3 for project1"
user="user1.git_svn"
user1_git_svn_sb3="user1_git_svn_sb3"
run "cd .."
run "mkdir $user1_git_svn_sb3"
run "cd $user1_git_svn_sb3"
run "git svn clone file://$svn_repo/layout3/project1 -s ."
run "tree -a"
run "cat .git/config"

#####################################################################
h1  "configure username/e-mail/color/etc."
run "git config user.name \"$user\""
run "git config user.email \"$user@domain\""

#####################################################################
h1 "rename master to trunk for better readability"
run "git branch -m master trunk"

#####################################################################
h1 "adding some useful configuration including aliases used later, the shared config is just used here for simplicty and is usually local only and not checked in !"
run 'echo -e "[include]\n    path=../shared.gitconfig" >> .git/config'
run "cat .git/config"
run "git config --list --local --includes"

#####################################################################
h1 "showing info in svn info format"
run "git svn info"
run "git svn info --url"

#####################################################################
h1 "showing logs in svn log format"
run "git svn log"
cmt "-v or --verbose"
run "git svn log -v"
run "git svn log --oneline"
run "git svn log -r 3"
run "git svn log -r 2:3"
run "git svn log -r 3:2"
run "git svn log --limit=1"
run "git svn log --show-commit"
run "git svn log --oneline --show-commit"

#####################################################################
h1 "showing logs using git log"

h2 "showing logs as usual"
run "git log"
run "git aliaslogall2"
run "git aliaslog2"

h2 "showing logs with svn revisions"
run "git aliaslogsvn"
run "git aliaslogsvnall"

run "git aliassvnnotessetall"
run "git aliaslogsvnall"

run "echo 'some more text' >> readme.txt"
run "git commit -m 'more text' readme.txt"

run "git aliassvnnotessetall"
run "git aliaslogsvnall"

run "echo 'even more text' > readme.txt"
run "git commit -m 'even more text' readme.txt"

run "git aliassvnnotessetunset" 
run "git aliaslogsvnall"

#h2 "just show current branch"
#run "git aliaslogsvn"

#####################################################################
h1 "committing changes to svn repository"

run "git svn dcommit"
run "git aliaslogsvn"
run "git aliassvnnotessetunset" 
run "git aliaslogsvn"

#####################################################################
h1 "receiving changes committed from svn side on git_svn side"

h2 "add some changes from svn side"
run "cd .."
run "cd $user1_svn_sb1/layout3/project1/trunk"
user="user1.svn"
run "svn status -u"
run "svn update"
run "echo 'some more text from user1' > readme.txt"
run 'svn commit -m "some more text from user1" readme.txt'

h2 "receive changes on git svn side"
run "cd ../../../.."
run "cd $user1_git_svn_sb3"
user="user1.git_svn"
run "git svn fetch"
run "git aliassvnnotessetall"
run "git aliaslogsvnall"
run "git svn rebase"
run "git aliaslogsvnall"

#####################################################################
h1 "generate some conflicts to show rebase issues"

user="user2.svn"
user2_svn_sb1="user2_svn_sb1"
h2 "create svn sandbox for $user"
run "cd .."
run "mkdir $user2_svn_sb1"
run "cd $user2_svn_sb1"
run "svn checkout file://$svn_repo/layout3/project1/trunk ."

h2 "add changes to create merge conflicts to be solved in user1.git_svn sandbox later"

run 'sed -i "s,c,cry_,g" verilog/carry_lookahead_adder.v'
run "svn commit --username $user verilog/carry_lookahead_adder.v -m 'c to cry_ (no conflict, only changed from user2.svn)'"

run 'sed -i "s,endmodule,endmodule // some note,g" verilog/full_adder_cla.v'
run "svn commit --username $user verilog/full_adder_cla.v -m 'note after endmodule (no conflict, no change from user1.git_svn at the same location)'"

run 'sed -i "s,full_adder_cla,fa_cla,g" verilog/full_adder_cla.v'
run "svn commit --username $user verilog/full_adder_cla.v -m 'module name change from full_adder_cla to fa_cla (conflicts with user1.git_svn: full_adder_cla to full_adder_carry_lookahead_adder)'"

run 'sed -i "s,c,carry_,g" verilog/full_adder_cla.v'
run 'sed -i "s,carry_ ,carry ,g" verilog/full_adder_cla.v'
run 'sed -i -r "s,carry_$,carry,g" verilog/full_adder_cla.v'
run 'sed -i "s,carry_),carry),g" verilog/full_adder_cla.v'
run "svn commit --username $user verilog/full_adder_cla.v -m 'c to carry_ (conflicts with user1.git_svn: reg to logic / prev to previous / full_adder_cla to full_adder_carry_lookahead_adder)'"

run 'sed -i "s,endmodule,endmodule // some comment,g" verilog/full_adder_cla.v'
run "svn commit --username $user verilog/full_adder_cla.v -m 'update of note - added a comment after endmodule (no conflict, no change from user1.git_svn at the same location)'"

#####################################################################
h1 "creating some conflicts and other changes from git svn side"
run "cd .."
run "cd $user1_git_svn_sb3"
user="user1.git_svn"

h2 "add local changes to create merge conflicts comming from a another user called user2.svn from svn side"

run 'sed -i "s,halve_adder,ha,g" verilog/halve_adder.v'
run 'git commit verilog/halve_adder.v -m "halve adder to ha (no conflict, only changed from user1.git_svn)"'

run 'sed -i "s,reg,logic,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "reg to logic (conflicts with user1.git_svn: c to carry_)"'

run 'sed -i "s,prev ,previous ,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "prev to previous in comment (conflicts with user1.git_svn: c to carry_)"'

run 'sed -i "s,full_adder_cla,full_adder_carry_lookahead_adder,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "module name change from full_adder_cla to full_adder_carry_lookahead_adder (conflicts with user1.git_svn: c to carry_ / full_adder_cla to fa_cla)"'

#####################################################################
h1 "get changes and solve conflicts"

# -------------------------------------------
h2 "first add some local modifications"
run 'sed -i "s,wire, wire ,g" verilog/halve_adder.v'
run 'git add verilog/halve_adder.v'
run 'sed -i "s,wire, wire ,g" verilog/halve_adder.v'
run 'sed -i "s,reg, logic,g" verilog/halve_adder.v'

# -------------------------------------------
h2 "use alias command sequence to auto stash and rebase tag"
run "grep alias-svn-stash-fetch-tag-rebase-dcommit-svnnotessetunset-unstash shared.gitconfig -A 14"
cmt "rebase rewrites history hence tags or branches should be created to get back to the state before rebase is done"
cmt "automatically stashing before an update helps to keep local changes"
cmt "in case of rebase conflicts the stash must be applied manually afterwards"

cmt "below will fail because of conflicts"
set +e
run "git alias-svn-stash-fetch-tag-rebase-dcommit-svnnotessetunset-unstash"
set -e
run "git aliassvnnotessetunset" 
run "git aliaslogsvnall"

# -------------------------------------------
h2 "solve rebase conflicts"
run 'git status'

# ------------
h3 "solving conflict (1/3)"
run 'git aliasdiffall verilog/full_adder_cla.v'
run 'git rebase --show-current-patch'
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,reg,logic,g" verilog/full_adder_cla.v'
#run 'sed -i "s,c),carry),g" verilog/full_adder_cla.v'
#run 'sed -i "s,carry_arry,carry,g" verilog/full_adder_cla.v'
run 'git aliasdiffall verilog/full_adder_cla.v'
run 'git add verilog/full_adder_cla.v'
#
cmt "below is a trick to avoid editor to pop up + modify message => required for continues flow in demonstration => usually interactive mode is fine"
run "mv .git/rebase-merge/message .git/rebase-merge/message2"
run "echo 'REBASE CONFLICT 1/3: ' > .git/rebase-merge/message"
run "cat .git/rebase-merge/message2 >> .git/rebase-merge/message"
run "rm -rf .git/rebase-merge/message2"
set +e
run "GIT_EDITOR=true git rebase --continue"
set -e

# ------------
h3 "solving conflict (2/3)"
run 'git aliasdiffall verilog/full_adder_cla.v'
run 'git rebase --show-current-patch'
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,prev ,previous ,g" verilog/full_adder_cla.v'
run 'git aliasdiffall verilog/full_adder_cla.v'
run 'git add verilog/full_adder_cla.v'
#
cmt "below is a trick to avoid editor to pop up + modify message => required for continues flow in demonstration => usually interactive mode is fine"
run "mv .git/rebase-merge/message .git/rebase-merge/message2"
run "echo 'REBASE CONFLICT 2/3: ' > .git/rebase-merge/message"
run "cat .git/rebase-merge/message2 >> .git/rebase-merge/message"
run "rm -rf .git/rebase-merge/message2"
set +e
run "GIT_EDITOR=true git rebase --continue"
set -e

# ------------
h3 "solving conflict (3/3)"
run 'git aliasdiffall verilog/full_adder_cla.v'
run 'git rebase --show-current-patch'
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,_la,_lookahead_adder,g" verilog/full_adder_cla.v'
run 'git aliasdiffall verilog/full_adder_cla.v'
run 'git add verilog/full_adder_cla.v'
#
cmt "below is a trick to avoid editor to pop up + modify message => required for continues flow in demonstration => usually interactive mode is fine"
run "mv .git/rebase-merge/message .git/rebase-merge/message2"
run "echo 'REBASE CONFLICT 3/3: ' > .git/rebase-merge/message"
run "cat .git/rebase-merge/message2 >> .git/rebase-merge/message"
run "rm -rf .git/rebase-merge/message2"
set +e
run "GIT_EDITOR=true git rebase --continue"
set -e

# -------------------------------------------
h2 "apply stash that was not unstashed beacuse of rebase conflict"
run "git stash pop"

# -------------------------------------------
h2 "show final status after solving conflict"
run "git status"
run "git aliassvnnotessetunset" 
run "git aliaslogsvnall"

#####################################################################
h1 "showing blame in svn format"
cmt "0 means locally changed but not committed to svn"
run "git svn blame verilog/full_adder_cla.v"
run "git svn blame --git-format verilog/full_adder_cla.v"
run "git blame verilog/full_adder_cla.v"

run "git alias-svn-stash-fetch-tag-rebase-dcommit-svnnotessetunset-unstash"
run "git aliaslogsvnall"

run "git svn blame verilog/full_adder_cla.v"
run "git svn blame --git-format verilog/full_adder_cla.v"
run "git blame verilog/full_adder_cla.v"

#####################################################################
# worktrees 
h1 "worktrees and none svn branches"
cmt "(feature) branches of an git-svn managed trunk/branch are possible, but need special handling"
cmt "such (feature) branches cannot be directly committed to svn, but need to be integrated to an existing git-svn managed trunk/branch first"

h2 "add worktree for feature1 branch"
user1_git_svn_sb3_wt1="user1_git_svn_sb3_wt1"
run "git branch feature1"
run "git worktree add ../$user1_git_svn_sb3_wt1 feature1"

h2 "some change to be integrated to none svn feature1 branch from trunk"
run 'sed -i "s,carry_ripple_adder,cra,g" verilog/carry_ripple_adder.v'
run 'git commit -m "change to cra from trunk side" verilog/carry_ripple_adder.v'

h2 "some change to be integrated to trunk from feature1 none svn branch"
run "cd ../$user1_git_svn_sb3_wt1"
run 'sed -i "s,fas,full_adders,g" verilog/carry_ripple_adder.v'
run 'git commit -m "change to cra from feature side" verilog/carry_ripple_adder.v'
run 'git aliaslogsvnall'

h2 "integrate changes from trunk to none svn feature1 branch"
cmt "rebase is required for none svn branches to integrate changes from an svn branch into it"
run "grep alias-worktree-rebase shared.gitconfig -A 15"
run 'git alias-worktree-rebase trunk'
run 'git aliaslogsvnall'

h2 "integrate changes from none svn feature1 branch to trunk"
cmt "merge using -ff-only (fast forward only) is mandatory to keep linear history required for pushing to svn"
cmt "only aligned none svn branches must be integrated"
cmt "alias-worktree-rebase must be run on branch to integrate before alias-worktree-merge is called"
run "cd ../$user1_git_svn_sb3"
run "grep alias-worktree-merge shared.gitconfig -A 15"
run 'git alias-worktree-merge feature1'
run 'git aliaslogsvnall'


#####################################################################
h1 "working with svn branches"

h2 "add branch using svn"
run "cd .."
run "cd $user2_svn_sb1"
run "svn update"
run "svn cp ^/layout3/project1/trunk ^/layout3/project1/branches/variant2 -m 'create svn variant2 branch'"

h2 "checkout new svn branch in own worktree"
run "cd .."
run "cd $user1_git_svn_sb3"
run "git svn fetch"
user1_git_svn_sb3_wt2="user1_git_svn_sb3_wt2"
run "git branch variant2 origin/variant2"
run "git worktree add ../$user1_git_svn_sb3_wt2 variant2"
run "cd ../$user1_git_svn_sb3_wt2"

h2 "create feature2 git svn branch for variant2 svn branch"
run "git branch variant2_feature2"
user1_git_svn_sb3_wt3="user1_git_svn_sb3_wt3"
run "git worktree add ../$user1_git_svn_sb3_wt3 variant2_feature2"
run "cd ../$user1_git_svn_sb3_wt3"

h2 "change something in feature2 git svn branch"
run "echo 'feature2' >> readme.txt"
run "git commit readme.txt -m 'feature2 change'"

h2 "merge back to svn variant2 branch"
run 'git alias-worktree-merge variant2_feature2'
run "git aliassvnnotessetunset" 
run 'git aliaslogsvnall'

h2 "upload to svn"
run "git svn dcommit"

h2 "add changes to trunk in parallel to variant2 branch using git svn"
run "cd ../$user1_git_svn_sb3"
run "sed -i 's,some more text,changes from trunk,g' readme.txt"
run "git commit verilog/halve_adder.v -m 'some local changes from before'"
run "git commit readme.txt -m 'changes from trunk'"
run "git svn dcommit"

h2 "merge variant2 svn branch using svn"
user="user2.svn"
user2_svn_sb2="user2_svn_sb2"
h2 "create svn sandbox for $user"
run "cd .."
run "mkdir $user2_svn_sb2"
run "cd $user2_svn_sb2"
run "svn checkout file://$svn_repo/layout3/project1/branches/variant2 ."
run 'echo -e "p\n" | svn merge ^/layout3/project1/trunk'
# solve conflict
run 'cat readme.txt | grep "changes from trunk" > readme.txt2'
run 'cat readme.txt | grep "feature2" >> readme.txt2'
run 'cp -f readme.txt2 readme.txt'
run 'svn resolved readme.txt'
run "svn commit -m 'merged trunk into variant2'"

h2 "merge trunk to variant2 svn branch using svn"
run "cd .."
run "cd $user2_svn_sb1"
run "svn update"
run 'svn merge ^/layout3/project1/branches/variant2'
run "svn commit -m 'merged variant2 into trunk'"

######
h2 "update git svn database and show merge structure"
run "cd .."
run "cd $user1_git_svn_sb3"
user="user1.git_svn"
run "git svn fetch"
run "git aliassvnnotessetunset" 
run 'git aliaslogsvnall'
run "git svn rebase"
run 'git aliaslogsvnall'

#####################################################################
h1 "git svn branch"
cmt "not used at the moment => use svn instead"

#####################################################################
h1 "merge of svn branches"
cmt "There is no working way available to merge svn branches. Must be done on svn side."

#####################################################################
h1 "notes"
cmt "used for svn revision numbers"

#####################################################################
h1 "tags"
cmt "used for local automatic rebase/merge tagging"

#####################################################################
h1 "rebase interactive"
cmt "works as usual with git and must only be applied to not released commits as rebase is used"
cmt "take care in case of git feature branches, any local merge/rebase to/from the base svn branch (e.g. trunk) count already as a release"

