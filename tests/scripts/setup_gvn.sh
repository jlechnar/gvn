
cat $GVN_BASE/.gitconfig.base >> .git/config
cat $GVN_BASE/.gitconfig.extensions >> .git/config
cat $GVN_BASE/.gitconfig.gvn | grep -v gvn-cmd >> .git/config

echo "gvn-cmd-annotate = \"!python3 ${GVN_ANNOTATE}\"" >> .git/config
echo "gvn-cmd-blame = \"!python3 ${GVN_BLAME}\"" >> .git/config

execute "git branch -m trunk" "Rename master to trunk to match name for gvn"
