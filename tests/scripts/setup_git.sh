
cwd=`pwd`

cat $GVN_BASE/.gitconfig.base | sed "s,~/.git_history,$cwd/../.git_history,g" | sed "s,length = 300,length = 99999,g" >> .git/config
cat $GVN_BASE/.gitconfig.extensions | sed "s,~/bin/bin_gvn/,$GVN_BASE/bin/,g" >> .git/config
cat $GVN_BASE/.gitconfig.gvn | sed "s,~/bin/bin_gvn/,$GVN_BASE/bin/,g" >> .git/config

