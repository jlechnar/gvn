
cat $GVN_BASE/.gitconfig.base >> .git/config
cat $GVN_BASE/.gitconfig.extensions >> .git/config
cat $GVN_BASE/.gitconfig.gvn | sed "s,~/bin/bin_gvn/,$GVN_BASE/bin/,g" >> .git/config

execute "git branch -m trunk" "Rename master to trunk to match name for gvn"

execute "$GVN umdb" "update map database"
