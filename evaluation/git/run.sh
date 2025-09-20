#!/bin/bash

# Description: GVN - Git sVN - git configuration and more for easier usage of git-svn, test suite
# Author:      jlechnar
# Licence:     GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Source:      https://github.com/jlechnar/gvn

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
h1 "create environment"
run "rm -rf $folder"
run "mkdir $folder"
run "cd $folder"

#####################################################################
h1 "create shared local remote repository"
run "mkdir local_shared_repo"
run "cd local_shared_repo"
local_shared_repo=`pwd`
run "git init --bare --shared=true ."
cmt "select rights properly (multiple options available) using --shared so that other users can push to repository"
run "tree -a"

#####################################################################
user="user1"
user1_sb1="user1_sb1"
h1 "create sandbox for $user"
run "cd .."
run "mkdir $user1_sb1"
run "cd $user1_sb1"
run "git clone $local_shared_repo ."
run "tree -a"
in_sandbox=1

#####################################################################
h1 "adding/removing content to stage + showing the status"
run "cp -R ../../data/* ."
run "tree"
run "git status"
h2 "files"
run "git add readme.txt"
run "git status"
h2 "folder / add links"
run "git add links"
run "git status"
h2 "using wildcards"
run "git add verilog/*.v"
run "git status"
cmt "empty folders are not supported, use a placeholder as workaround"
run "git add empty_folder"
run "git status"
h2 "status in a subfolder"
run "cd verilog"
run "git status"
cmt "status is shown relative to the current folder"

h2 "remove unwanted added file from stage"
run "git rm --cached file_not_to_be_tracked.v"
run "git status"

h2 "modify a staged file"
run "echo test > carry_ripple_adder.v"
run "git status"

h2 "revert the change"
run "git restore carry_ripple_adder.v"
run "git status"
run "cd .."

#####################################################################
h1  "config - git configuration"
cmt "ATTENTION: before committing content at least the username/e-mail must be configured properly"
cmt "git supports configuration on multiple levels: system (e.g. /etc/gitconfig) / home (~/.gitconfig) / sandbox (<sandbox_folder>/.git/config)"
cmt "in case of same configuration in multiple levels the following option override priority is used: sandbox > home > system"
run "cat .git/config" 

h2  "configure username/e-mail/color/etc."
run "git config user.name \"$user\""
run "git config user.email \"$user@domain\""

h2  "show configuration"
run "cat .git/config" 
run "git config --local --list"

h2  "manual edit configuration (add some more handy configurations)"
cmt "manual changing the configuration is possible"
cmt "Note that configuration is not shared with others, but possible by including a git managed configuration file"
run 'echo -e "[include]\n    path=../shared.gitconfig" >> .git/config'
run "cat .git/config" 
run "git config --list --local --includes"
run "git add shared.gitconfig"
run "git status"

#####################################################################
h1  "commit the contents of the stage to the sandbox repository"
cmt "skip -m 'message' to get to interactive commit message editing"
run "git commit -m 'initial commit'"

#####################################################################
h1  "log - show the commit history"
cmt "git uses a hash instead of a number for each commit, numbers are not possible due to the decentralized nature of git"
run "git log"
cmt "some more options, which will be handy later"
cmt "show all commits of all branches"
run "git log --all"
cmt "show all commits using a graph to show commit history"
run "git log --all --graph"
cmt "show reference names (branches, tags, etc.)"
run "git log --all --graph --decorate"
cmt "show short logs"
run "git log --oneline"
cmt "combine them all"
run "git log --oneline --all --graph --decorate"
cmt "lets try these afterwards when there are more commits"

#####################################################################
h1 "commit messages"
cmt "git supports basic structured commit messages of the form:"
cmt "  <SUMMARY>       (one line only)"
cmt "  <EMPTY LINE>"
cmt "  <DETAILS>       (multiple lines)"
run "echo 'dummy data' > commit_message_test.file"
run "git add commit_message_test.file"
run "git commit -m $'commit message structure demo\n\ndetailed message can contain\nmultiple lines\n\nit was added to show the commit message structure\nand it can contain any arbitrary message'"
run "git log"
cmt "only summary is shown when using --oneline, this is handy for getting a fast overview of the changes"
run "git log --oneline"
cmt "recommendation is to place: unique commit identifiers/categories/ticket_numbers etc. in front of the <SUMMARY> for better readability"

#####################################################################
h1 "push the contents of the sandbox repository to the shared local remote repository"
run "git status"
cmt "use \"git branch --unset-upstream\" to fixup => this warning is because there is no remote repo branch known for master as the repo is empty - solved by first push"
run "git push"

#####################################################################
h1 "remotes - show connected remote repositories by name (+remote URL)"
cmt "default branch is called origin"
run "git remote"
run "git remote -v"

#####################################################################
h1 "branches - show branches (current, all, all with details and with more details)"
cmt "default branch is called master"
run "git branch"
run "git branch -a"
run "git branch -va"
cmt "below shows additonally the upstream connection (where default push/pull goes to/from)"
run "git branch -vva"

#####################################################################
h1  "add dummy repo's and add them as remote"
cmt "multiple remotes can be added of the same repo or even other repos, which enables to implement all kind of workflows"
run "cd .."
in_sandbox=0
run "mkdir local_shared_repo2"
run "cd local_shared_repo2"
local_shared_repo2=`pwd`
run "git init --bare --shared=true ."
run "cd .."
run "cd $user1_sb1"
in_sandbox=1
h2  "add the new remote repos"
run "git remote add local_shared_repo2 $local_shared_repo2"
run "git remote -v"
run "git branch -vva"
h2  "push the current branch to the remote repo's"
run "git push local_shared_repo2"
run "git branch -vva"

#####################################################################
h1 "ignoring files"
run "git status"
cmt "ignores are immediately effective"
run "echo \"file_to_be_ignored.txt\" > .gitignore"
run "git status"
h2 "using wildcards"
run "echo \"*.ignore_me\" >> .gitignore"
run "git status"
h2 "showing ignored files"
run "git status --ignored"
h2 "add remaining files to get clean status"
run "echo \"*folder_not_to_be_tracked\" >> .gitignore"
run "echo \"verilog/file_not_to_be_tracked.v\" >> .gitignore"
run "git status"
run "git status --ignored"
h2 "sharing files to be ignored"
run "git add .gitignore"
run "git commit -m 'adding git ignores'"

#####################################################################
h1 "common issue: user is in the middle of feature implementation and gets a request to do something else"
cmt "SOLUTION 1: commit current changes"
cmt "SOLUTION 2: use stash to store intermediate changes"
cmt "SOLUTION 3: avoid it: work on branches for each feature"
cmt "SOLUTION 4: avoid it: use worktree's"

#####################################################################
h1 "stashes (SOLUTION 2) + advanced log + aliases"
cmt "stash is similar to a commit but it does not modify the branch"
cmt "instead it creates a 'one branch with one commit only'"
cmt "a stack like approach is used for handling the stashes"
run "echo 'some change' >> readme.txt"
run "git rm links/fa.sv"
run "rm links/ha.sv"
run "echo 'remove all contents' > verilog/carry_ripple_adder.v"
h2 "stash selected file"
run "git stash -- verilog/carry_ripple_adder.v"
run "git status"
h2 "stash all changed files"
run "git stash"
run "git status"
h2 "list all stashes"
run "git stash list"
h2 "apply stash and drop it"
cmt "if there are conflicts during stash pop then the stash is not automatically removed !"
run "git stash pop"
run "git stash list"
run "git status"
h2 "stash all changed files + adding a title for the stash"
run "git stash -m 'stash with certain name'"
run "git stash list"
h2 "apply stash but keep it for other usage"
run "git stash apply"
run "git stash list"
run "git status"
h2 "restore all local changes at once"
run "git restore :/"
h2 "show change list of top most stash element"
run "git stash show"
h2 "show change list of selected stash element"
run "git stash show 1"
h2 "show detailed changes of top most or selected stash element"
run "git stash show -p"
run "git stash show -p 1"
run "git stash show -p stash@{1}"
h2 "add more stashes"
run "echo 'remove all whatever' > verilog/carry_ripple_adder.v"
run "git stash -m 'another change to cra' -- verilog/carry_ripple_adder.v"

h2 "showing the stashes in log"
run "git stash list"
run "git log -g stash"
cmt "git log does not show stashes at all, --all shows only some, --decorate additionally show all reference names (e.g. branches, tags, stashes, etc.)"
run "git log --all --decorate"
run 'git log --all --decorate $(git reflog show --format="%h" stash)'
cmt "--online gives a one line list instead of full blown log"
run 'git log --online --all --decorate $(git reflog show --format="%h" stash)'
cmt "--graph shows how the internal commit graph history"
cmt "we can see two entries for each stash entry - index on master (copy of part where stash is applied + stash itself => used for calculating patch differences)"
run 'git log --oneline --graph --decorate --all $(git reflog show --format="%h" stash)'
run "git stash list"

h2 "aliases can be used to avoid remembering/typing long commands"
cmt "it is possible to call git with different options or any other commands (e.g. shell scripts)"
run "git config --local alias.aliaslogall \"log --oneline --graph --decorate --all\""
cmt "sometimes its more complex to get aliases properly running"
run "git config --local alias.aliaslogallstash \"!f() { git reflog show --format=\\\"%h\\\" stash | git log --oneline --graph --decorate --all; }; f\""
cmt "adding alias for bash command"
# below is a quick hack to get around issues with esacpe sequences and calling run '...'
#run echo aliasanycmd = \"\!bash -c \'cd -- \\\"\$\{GIT_PREFIX:-.\}\\\"\; any_cmd.sh -- \\\"\$\@\\\"\' --\" >> .git/config
set -x
echo "[alias]" >> .git/config
echo aliasanycmd = \"\!bash -c \'cd -- \\\"\$\{GIT_PREFIX:-.\}\\\"\; any_cmd.sh -- \\\"\$\@\\\"\' --\" >> .git/config
set +x
run 'tail -n 1 .git/config'
run "git aliaslogallstash"
run "git config --local --list | grep alias"

#####################################################################
h1 "branches (SOLUTION 3)"

h2 "create branch from current"
run "git status"
run "git branch feature1"
run "git checkout feature1"
run "git aliaslogall"

h2 "do some changes"
run "echo 'do some modifications in branch' >> verilog/halve_adder.v"
run "git commit verilog/halve_adder.v -m 'some change in branch'"
run "echo 'some more changes' >> verilog/full_adder.v"
run "git commit verilog/full_adder.v -m 'another change in branch'"
run 'sed -i "s,full_adder,fa,g" verilog/full_adder.v'
run "git commit verilog/full_adder.v -m 'rename full_adder to fa'"
run "git aliaslogall"

h2  "try to checkout different branch in case of local modifications"
cmt 'this will break as data would be lost => stash/commit/worktree'
run 'sed -i "s,halve_adder,ha,g" verilog/halve_adder.v'
set +e
run "git checkout master"
set -e
run "git commit verilog/halve_adder.v -m 'rename halve_adder to ha'"
run "git checkout master"
run "git push"

h2 "transfer new local feature1 branch to remote repository"
run "git checkout feature1"
cmt "simple push will fail es we first need to setup upstream first"
set +e
run "git push"
set -e
run "git branch -vva"
run "git push --set-upstream origin feature1"
run "git push"
run "git aliaslogall"
run "git branch -vva"

#####################################################################
h1 "diff"
h2 "prepare some changes to show"
run "git stash apply 0"
run "git stash apply 1"
run 'sed -i "s,wire, wire ,g" verilog/halve_adder.v'
run 'sed -i "s,reg, logic,g" verilog/halve_adder.v'
run 'sed -i "s,modifications,mods,g" verilog/halve_adder.v'
run 'sed -i "s,c_,carry_,g" verilog/full_adder.v'
run "git diff"
cmt 'gui mode can be started by using difftool instead of diff command'
cmt '  > git difftool'
cmt 'gui directory diff is supported e.g. via meld'
cmt '  > git difftool -d'
cmt 'files/paths can be used to show only diffs of certain files'
run "git diff verilog/full_adder.v"
cmt 'wordwise diff reduces overhead'
run "git diff --word-diff verilog/full_adder.v"
cmt 'ignoring spaces'
run "git diff '--word-diff-regex=[^[:space:]]' verilog/full_adder.v"
cmt 'reduce diff overhead to just use just color encoding'
run "git diff '--word-diff-regex=[^[:space:]]' --word-diff=color verilog/full_adder.v"
cmt 'just show lines that changed - no context around the diff'
run "git diff '--word-diff-regex=[^[:space:]]' --word-diff=color -U0 verilog/full_adder.v"
cmt 'some more options that can be handy'
run "git diff '--word-diff-regex=[^[:space:]]' --word-diff=color -U0 --ignore-all-space --ignore-blank-lines --ignore-space-change verilog/full_adder.v"
run "git config --local alias.aliasdiffall \"diff '--word-diff-regex=[^[:space:]]' --word-diff=color -U0 --ignore-all-space --ignore-blank-lines --ignore-space-change\""
cmt 'color encoding is handy in commandline interface but cannot be used with difftool !'

h2 "add all changes and directly commit them"
run "git commit -a -m 'changes to files'"
h2 "diff changes for commit"
cmt 'carret/^ is used for relative naviation to reference name e.g. HEAD^ means one commit before head'
run "git aliasdiffall HEAD^..HEAD verilog/full_adder.v"
h2 "branch names are also references"
run 'git aliasdiffall feature1..master verilog/full_adder.v'
h2 "commit hashes can also be used"
hash1=`git log -n 1 --pretty=format:"%H" master`
hash2=`git log -n 1 --pretty=format:"%H" feature1`
run "git aliasdiffall $hash2..$hash1 verilog/full_adder.v"
cmt 'all these can be used with difftool too'

#####################################################################
h1 "merge"
cmt "h are used to integrate changes from one branch to another one"
cmt "merging is used to integrate all changes from another branch to the current one"
cmt "the changes are combined without changing the history"
cmt "mergin just adds another commit where the changes are merged together on the working branch where the merge is started"

h2 "add local changes to create merge conflicts comming from a another user called user2 via remote repository"

run 'sed -i "s,reg,logic,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "reg to logic (conflicts with user2: c to carry_)"'

run 'sed -i "s,prev ,previous ,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "prev to previous in comment (conflicts with user2: c to carry_)"'

run 'sed -i "s,full_adder_cla,full_adder_carry_lookahead_adder,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "module name change from full_adder_cla to full_adder_carry_lookahead_adder (conflicts with user2: c to carry_ / full_adder_cla to fa_cla)"'


#################################
user="user2"
user2_sb1="user2_sb1"
h1 "create sandbox for $user"
in_sandbox=0
run "cd .."
run "mkdir $user2_sb1"
run "cd $user2_sb1"
cmt "below is an alternative way to clone"
run "git init ."
run "git remote add origin $local_shared_repo"
run "git fetch"
run "git checkout master"
in_sandbox=1
run "git config user.name \"$user\""
run "git config user.email \"$user@domain\""
run "git config --local alias.aliaslogall2 \"log --oneline --graph --decorate --all '--date=format-local:%Y-%m-%d %H:%M:%S' --pretty=format:\\\"%C(yellow)%h%C(reset) - %C(blue)%an%C(reset), %C(green)%ad%C(reset) : %s %C(auto)%d%C(reset)\\\"\""
run "git aliaslogall2"
run "git branch -vva"
run "git status"

h2 "add changes to create merge conflicts to be solved in user1 sandbox later"

run 'sed -i "s,c,cry_,g" verilog/carry_lookahead_adder.v'
run 'git commit verilog/carry_lookahead_adder.v -m "c to cry_ (no conflict, only changed from user2)"'

run 'sed -i "s,endmodule,endmodule // some note,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "note after endmodule (no conflict, no change from user1 at the same location)"'

run 'sed -i "s,full_adder_cla,fa_cla,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "module name change from full_adder_cla to fa_cla (conflicts with user1: full_adder_cla to full_adder_carry_lookahead_adder)"'

run 'sed -i "s,c,carry_,g" verilog/full_adder_cla.v'
run 'sed -i "s,carry_ ,carry ,g" verilog/full_adder_cla.v'
run 'sed -i -r "s,carry_$,carry,g" verilog/full_adder_cla.v'
run 'sed -i "s,carry_),carry),g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "c to carry_ (conflicts with user1: reg to logic / prev to previous / full_adder_cla to full_adder_carry_lookahead_adder)"'

run 'sed -i "s,endmodule,endmodule // some comment,g" verilog/full_adder_cla.v'
run 'git commit verilog/full_adder_cla.v -m "update of note - added a comment after endmodule (no conflict, no change from user1 at the same location)"'

h2 "transfer to remote for merging"
run 'git push'
run "git aliaslogall2"
run "git status"

#################################
h2 "change back to user1"
user="user1"
run "cd ../$user1_sb1"
run "git checkout feature1"
run "git pull"
run "git fetch"
run "git checkout master"
run "git pull"
run "git config --local alias.aliaslogall2 \"log --oneline --graph --decorate --all '--date=format-local:%Y-%m-%d %H:%M:%S' --pretty=tformat:\\\"%C(yellow)%h%C(reset) - %C(blue)%an%C(reset), %C(green)%ad%C(reset) : %s %C(auto)%d%C(reset)\\\"\""
run "git config --local alias.aliaslog2 \"log --oneline --graph --decorate '--date=format-local:%Y-%m-%d %H:%M:%S' --pretty=tformat:\\\"%C(yellow)%h%C(reset) - %C(blue)%an%C(reset), %C(green)%ad%C(reset) : %s %C(auto)%d%C(reset)\\\"\""
run "git aliaslogall2"

#################################
h2 "create a new branch to show merge (just for demonstration to keep master state for later use)"
run 'git checkout -b master_duplicate_for_merge master'
cmt 'creating branches works on references and also on commit hashes'
hash1=`git log -n 1 --pretty=format:"%H" master`
run "git checkout -b master_duplicate_for_merge_using_hash $hash1"
run 'git checkout master_duplicate_for_merge'
h3 "do the merge of user1 and user2 changes"
set +e
run 'git merge feature1'
set -e
run "git status"
cmt "HINT: if anything went wrong operation can be aborted e.g. in case of unexpected conflicts"
run 'git merge --abort'
run "git status"
set +e
run 'git merge feature1'
set -e
cmt "merge results in expected merge conflicts that need to be solved manually"
cmt "HINT: for graphical merging conflicts use: git mergetool <filename>"
#run "git aliaslogall2"
#
h3 "show differences ours vs. base vs. theirs (3 way merge style)"
run "git diff verilog/full_adder_cla.v"
#
h3 "use checkout to obtain different versions of the code"
#
h3 "theirs means the code of the branch to merge in (feature1)"
run "git checkout --theirs verilog/full_adder_cla.v"
run "git diff HEAD verilog/full_adder_cla.v"
#
h3 "ours means the code of the branch to merge to (master_duplicate_for_merge)"
run "git checkout --ours verilog/full_adder_cla.v"
run "git diff HEAD verilog/full_adder_cla.v"
#
h3 "merge means the merged code of both - originally created by the merge"
run "git checkout --merge verilog/full_adder_cla.v"
run "git diff HEAD verilog/full_adder_cla.v"
#
h3 "solving conflict"
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,_la,_lookahead_adder,g" verilog/full_adder_cla.v'
run 'sed -i "s,_arry,,g" verilog/full_adder_cla.v'
run 'sed -i "s,prev ,previous ,g" verilog/full_adder_cla.v'
run 'sed -i "s,reg,logic,g" verilog/full_adder_cla.v'
run 'git add verilog/full_adder_cla.v'
#
h3 "concluding merge (using commandline message. Note that git commit is enough and would bring up the message editor.)"
run "git commit -a -m 'Merge branch \"feature1\" into master_duplicate_for_merge'"
run 'git aliaslog2'

#################################
h2 'opposite direction merge demonstration'
run 'git checkout feature1'
run 'git checkout -b feature1_duplicate_for_merge feature1'
run 'git checkout feature1_duplicate_for_merge'
set +e
run 'git merge master'
set -e
run "git status"
run "git checkout --theirs verilog/full_adder_cla.v"
run 'sed -i "s,_la,_lookahead_adder,g" verilog/full_adder_cla.v'
run 'sed -i "s,_arry,,g" verilog/full_adder_cla.v'
run 'sed -i "s,prev ,previous ,g" verilog/full_adder_cla.v'
run 'sed -i "s,reg,logic,g" verilog/full_adder_cla.v'
run "git commit -a -m 'Merge branch \"master\" into feature1_duplicate_for_merge'"
run "git aliaslog2 feature1 master master_duplicate_for_merge feature1_duplicate_for_merge"

#####################################################################
h1 "rebase"
cmt "rebase is used to integrate all the changes happend in between on the base branch (where the feature branch was forked off) into the feature branch"
cmt "the idea is to get a linear history, therefore the feature branch gets replaced by a 'new' feature branch with the same name, where each and every commit that was done on the 'old' feature branch is applied again in the same sequence on the top of the of the base branch"
cmt "All these commits will get a new commit hash id, and there is no easy way back to the state before the rebase"
cmt "RECOMMENDATION: Automatically add a tag (or branch) pointing to the 'old' feature branch, to keep the history and have an easy way back."
cmt "PITFALL / IMPORTANT RULE: rebase must only be used to changes that no other user has seen before (only local changes by one user are allowed). REASON: rebase rewrites the history"

h2 'create own branch for feature1 => feature1_duplicate_for_rebase and to rebase'
run 'git checkout feature1'
run 'git checkout -b feature1_duplicate_for_rebase feature1'
run 'git checkout feature1_duplicate_for_rebase'
set +e
run 'git rebase master'
set -e
run 'git status'
run "git aliaslog2 master feature1 feature1_duplicate_for_rebase"
#run "git aliaslogall2"
run 'git diff'

h3 "HINT: use checkout to obtain different versions of the code can be used but --theirs and --ours are exchanged as the base for the rebase if the branche to rebase onto !!!"
#
h3 "theirs means the code of the branch to rebase in (feature1)"
run "git checkout --theirs verilog/full_adder_cla.v"
run "git diff HEAD verilog/full_adder_cla.v"
#
h3 "ours means the code of the branch to merge to (master_duplicate_for_merge)"
run "git checkout --ours verilog/full_adder_cla.v"
run "git diff HEAD verilog/full_adder_cla.v"
#
h3 "merge means the merged code of both - originally created by the merge"
run "git checkout --merge verilog/full_adder_cla.v"
cmt "Commit messages in merge comments are lost, instead ours/theirs/base is used => this seems to be a bug ?!"
run "git diff HEAD verilog/full_adder_cla.v"

h3 "aborting a rebase can be done at any stage during rebase"
run 'git status'
run 'git rebase --abort'
run 'git status'

h3 "Add command that creates a tag before rebase operation starts (details to tags will be shown later). Branches would also be fine (matter of taste)."
cmt "RECOMMENDATION: Good practice is to have a tag/branch name prefix for filtering these dummy tags/branches!"
set -x
echo "[alias]" >> .git/config
echo aliasrebasewithtag = \"\!bash -c \'cd -- \\\"\$\{GIT_PREFIX:-.\}\\\"\; set -x\; set -e\; git tag -a tag_before_rebase -m \"tag_before_rebase\"\; git rebase -- \\\"\$\@\\\"\' --\" >> .git/config
set +x

h3 "finish rebase by iteratively solving all conflicts"
cmt "Note that during a rebase operation the each commit is applied in the same sequence as they were commited originially"
set +e
run 'git aliasrebasewithtag master'
set -e
run "git aliaslog2 master feature1 feature1_duplicate_for_rebase tag_before_rebase"

h3 "solving conflict (1/3)"
run 'git rebase --show-current-patch'
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,reg,logic,g" verilog/full_adder_cla.v'
run 'sed -i "s,c),carry),g" verilog/full_adder_cla.v'
run 'sed -i "s,carry_arry,carry,g" verilog/full_adder_cla.v'
run "git diff"
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

h3 "solving conflict (2/3)"
run 'git rebase --show-current-patch'
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,prev ,previous ,g" verilog/full_adder_cla.v'
run "git diff"
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

h3 "solving conflict (3/3)"
run 'git rebase --show-current-patch'
run "git checkout --ours verilog/full_adder_cla.v"
run 'sed -i "s,_la,_lookahead_adder,g" verilog/full_adder_cla.v'
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

h3 "show graph"
run "git aliaslog2 master feature1 feature1_duplicate_for_rebase"


h3 "compare to merge - no differences are expected !"
run "git aliaslogall2"
run "git diff master_duplicate_for_merge..feature1_duplicate_for_rebase"
run "git diff feature1_duplicate_for_merge..feature1_duplicate_for_rebase"

#####################################################################
h1 "tags"

h2 "add/delete local tags"
run "git checkout master"
run 'git tag -a mytagtoberemoved -m "my tag to be removed"'
run "git tag -d mytagtoberemoved"
run 'git tag -a mytag_feature1 feature1 -m "my tag feature1 local only"'
run 'git tag -a mytag_master_local_only -m "my tag master local only"'
run 'git tag -a mytag_master_shared_with_remote -m "my tag to be shared with remote"'

h2 "list local tags"
run "git tag"
run "git show-ref --tags"
h2 "list remote tags"
run "git ls-remote --tags"

h2 "share tags"
run "git push origin tag mytag_master_shared_with_remote"
run "git show-ref --tags"
run "git ls-remote --tags"

h2 "get tags from remote for user2"
run "pwd"
run "cd ../user2_sb1"
user="user2"
set +e
run "git show-ref --tags"
set -e
run "git ls-remote --tags"
run "git fetch --tags"

h2 "delete remote tags via user2 (just to show how to do it but this is not recommended !!!)"
run 'git tag -a mytag_master_shared_to_remove -m "my tag master shared to be remove"'
run "git push origin tag mytag_master_shared_to_remove"
run "git show-ref --tags"
run "git ls-remote --tags"
run "git push --delete origin mytag_master_shared_to_remove"
run "git show-ref --tags"
run "git ls-remote --tags"

h2 "update removed tags for user1"
run "cd ../user1_sb1"
user="user1"
run "git show-ref --tags"
run "git ls-remote --tags"
run "git fetch --tags"
run "git show-ref --tags"
cmt "update does not work ! manual rework and exact knowledge is required to update here"
run "git fetch --prune --prune-tags"
run "git show-ref --tags"
cmt "PITFALL: all local tags that do not exist remote are removed"
cmt "RECOMMENDATION: never ever delete (/move/rename) remote tags unless local tags are not relevant at all"

#####################################################################
h1 "worktree (SOLUTION 4)"

h2 "list worktrees"
run "git worktree list"

h2 "add worktree"
user1_sb2="user1_sb2"
run "tree .git/ > tree_of_.git_dir_before_worktree"
run "git worktree add ../$user1_sb2 feature1"
run "git worktree list"
run "cat ../$user1_sb2/.git"
run "tree .git/ > tree_of_.git_dir_after_worktree"
set +e
run "diff tree_of_.git_dir_before_worktree tree_of_.git_dir_after_worktree"
set -e

h2 "add worktree of branch already in use is not possible !"
cmt "each worktree must be bound to unique reference"
user1_sb3="user1_sb3"
set +e
run "git worktree add ../$user1_sb3 feature1"
set -e

h3 "create branch without checking it out at the same time"
run "git branch feature1a feature1"

h3 "use duplicated branch for new worktree"
run "git worktree add ../$user1_sb3 feature1a"
run "git worktree list"

h2 "remove worktree"
run "git worktree list"
run "git worktree remove ../$user1_sb3"
run "git worktree list"
cmt "usually this breaks as there are local uncommitted changes and/or local untracked files, use option -f instead"

h2 "remove worktree with changes"
run "git worktree add ../$user1_sb3 feature1a"
run "cd ../$user1_sb3"
run "cat test > test"
set +e
run "git worktree remove ../$user1_sb3"
set -e
run "git worktree list"
run "cd ../$user1_sb2"
set +e
run "git worktree remove ../$user1_sb3"
set -e
cmt "fails because there is a local file that is not tracked"
run "git worktree list"
run "cd ../$user1_sb3"
run "echo 'some more changes' >> verilog/full_adder.v"
run "git status"
run "cd ../$user1_sb2"
set +e
run "git worktree remove ../$user1_sb3"
set -e
cmt "fails because there is a local file that is not tracked and a changed file (changed file alone would also be enough !)"
run "git worktree list"
cmt "finally force removal does the trick"
cmt "RECOMMENDATAION: Double check contents before delete as there is no way to recover from this using git."
run "git worktree remove --force ../$user1_sb3"
run "git worktree list"

h3 "alternative use stash to save changes before removing worktree"
run "git worktree add ../$user1_sb3 feature1a"
run "cd ../$user1_sb3"
run "dd if=/dev/urandom bs=1024 count=10000 of=test_10MB conv=notrunc"
run "echo 'some more changes' >> verilog/full_adder.v"
cmt "use stash to save all changes including untracked files"

# wait for network - else du below returns wrong values
sleep 5

run "du -sh ../*"
run "git stash --include-untracked"
run "du -sh ../*"

run "cd ../$user1_sb2"
run "git status"
run "git worktree remove ../$user1_sb3"
run "git worktree list"
cmt "restore stored data on different worktree including untracked files (--include-untracked)"
cmt "note that this is also possible with tracked only (without option)"
cmt "note that this is also possible with untracked only (--only-untracked)"
cmt "note that this is also possible without removing the worktree => transfer changes between worktrees can be done by this method"
cmt "keep 1MB file for later usage"
run "git stash apply"
run "git status"

h3 "alternative remove worktree via remove"
run "git worktree add ../$user1_sb3 feature1a"
run "rm -rf ../$user1_sb3"
run "git worktree list"
run "git worktree prune"
run "git worktree list"

h3 "cleanup"
run "cd ../$user1_sb1"
run "git worktree remove --force ../$user1_sb2"

#####################################################################
h1 "list files in database sorted by size"

h2 "for a specific reference (e.g. HEAD)"
run "git ls-tree -r -l --abbrev --full-name HEAD | sort -n -r -k 4 | head -n 10"

h2 "for the complete database"
run "git rev-list --objects --all | git cat-file --batch-check='%(objectsize) %(rest)' | sort -k1 -h | tail -n 10"
# %(objecttype) %(objectname) %(objectsize) %(rest)

#####################################################################
h1 "trigger garbage collection (get rid of 10MB file in stash from untracked files)"
run "git stash drop"
run "git gc"
run "git rev-list --objects --all | git cat-file --batch-check='%(objectsize) %(rest)' | sort -k1 -h | tail -n 10"
cmt "ATTENTION: Be careful with stashing untracked files. All files in the workspace would get included to the git repository and so could then increase the repository size massively."

#####################################################################
h1 "list files"
run "git ls-files"
run "cd verilog"
run "git ls-tree -r master --name-only"
run "git ls-tree -r master --name-only --full-tree"
run "cd .."
set -x
echo "[alias]" >> .git/config
echo aliasfindall = \"\!bash -c \'cd -- \\\"\$\{GIT_PREFIX:-.\}\\\"\; set -x\; set -e\; git ls-tree -r HEAD --name-only --full-tree \| grep -- \\\"\$\@\\\"\' --\" >> .git/config
set +x

run "cd verilog"
run "git aliasfindall adder"
run "cd .."
run "git aliasfindall adder"

#####################################################################
h1 "search for contents"
run "git grep carry"

#####################################################################
h1 "cat contents of file at reference"
run "git show HEAD:verilog/full_adder_cla.v"
run "git show master:verilog/full_adder_cla.v"
run "git show feature1^^:verilog/full_adder_cla.v"
hash1=`git log -n 1 --pretty=format:"%H" feature1`
run "git show $hash1:verilog/full_adder_cla.v"

#####################################################################
h1 "blame"
run 'git blame verilog/full_adder_cla.v'
run 'sed -i "s,previous ,prev ,g" verilog/full_adder_cla.v'
run 'git blame verilog/full_adder_cla.v'
run 'git blame HEAD verilog/full_adder_cla.v'

#####################################################################
h1 "log follow"
cmt "for single files log follow can be used to track changes"
run 'GIT_PAGER=cat git log --follow -p verilog/full_adder_cla.v'
run 'GIT_PAGER=cat git log --follow -p -w -U0 --word-diff-regex=[^[:space:]] verilog/full_adder_cla.v'

#####################################################################
h1 "interactive staging"

h2 "add some changes to move between stage and workspace"
run 'sed -i "s,previous ,prev ,g" verilog/full_adder_cla.v'
run 'sed -i "s,some comment,some changed comment,g" verilog/full_adder_cla.v'
run 'sed -i "s,fa_carry_lookahead_adder,fa_carry_lookahead_add,g" verilog/full_adder_cla.v'
run 'git status'
run 'git diff'
run 'git diff --staged'

h2 "stage changes interactively with selection"
run 'echo -e "5\n1\n\ns\ny\ny\nn\nq\n" | git add -i verilog/full_adder_cla.v'
run 'git status'
run 'git diff'
run 'git diff --staged'

h2 "restore all"
run 'git restore --staged verilog/full_adder_cla.v'

h2 "stage changes interactively without selection"
run 'echo -e "s\ny\ny\nn\n" | git add -p verilog/full_adder_cla.v'
run 'git status'
run 'git diff'
run 'git diff --staged'

h2 "unstage changes interactively"
run 'echo -e "s\ny\nn\n" | git restore --staged -p verilog/full_adder_cla.v'
run 'git status'
run 'git diff'
run 'git diff --staged'

h2 "revert changes in workspace interactively"
run 'echo -e "y\nn\n" | git restore -p verilog/full_adder_cla.v'
run 'git status'
run 'git diff'
run 'git diff --staged'

h2 "revert all staged changes at once to workspace"
run "git restore --staged :/"

h2 "revert all workspace changes at once"
run "git restore :/"

#####################################################################
h1 "interactive rebase"
cmt "ATTENTION: as usually for rebase apply only to commits that were not distributed to anybody else ! This is due to the history rewriting of rebase command !"

run "git checkout feature1"
run 'git aliaslog2'

h2 "change commit message (rebase is used in background !)"
run 'git commit --amend -m "updated commit message of top most commit"'
run 'git aliaslog2'

# FIXME: no easy way to show interactive without real user interaction below
h2 "interactive rebase for more options"
cmt "  change commit message"
cmt "  fix/reorder/delete commits"
cmt "  split/reopen commits for editing"
cmt "  squash/combine multiple commits"
cmt ""
cmt "manual key strokes to enter next: replace pick with reword and store file and then change the message"
cmt "  e.g. vim:"
cmt "  i<delete><delete><delete><delete>reword<Escape>:wq!<enter>"
cmt "  i CHANGED MESSAGE <Escape>:wq<enter>"
waitforenter
run 'git rebase -i feature1^'
run 'git aliaslog2'

#####################################################################
# h1 "changing HEAD position / reverting commits"
#
# git reset --hard <commitish> => reset head to that item
#
# FIXME

#####################################################################
# h1 "submodules"
#
# FIXME

#####################################################################
# h1 "subtree"
#
# FIXME

#####################################################################
# h1 "notes"
#
# FIXME

#####################################################################
# h1 "lfs"
#
# FIXME

#####################################################################
# h1 "hooks"
#
# FIXME

#####################################################################
h1 "reflog"
cmt "if you have any issue, git has a history feature of all changes"
run "GIT_PAGER=cat git reflog"
run "GIT_PAGER=cat git reflog --relative-date"

#####################################################################
h1 "check the database for consistency (filesystem check)"
run "git fsck"

#####################################################################
h1 "clean up repository from dangling blobs = stuff that was added to staging area but never got committed, dangling commits = commits with no connection to any other commit/refrence/branch/tag"
cmt "this also clears reflog !"
run "git reflog expire --expire=now --all"
run "git gc --prune=now"
run "git fsck"
run "GIT_PAGER=cat git reflog"

