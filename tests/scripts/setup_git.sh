
cwd=`pwd`

cat $GVN_BASE/.gitconfig.base >> .git/config
cat $GVN_BASE/.gitconfig.extensions | sed "s,~/bin/bin_gvn/,$GVN_BASE/bin/,g" >> .git/config
cat $GVN_BASE/.gitconfig.gvn | sed "s,~/bin/bin_gvn/,$GVN_BASE/bin/,g" >> .git/config

