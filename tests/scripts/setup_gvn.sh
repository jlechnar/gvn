
source ../scripts/setup_git.sh

execute "$GIT branch -m trunk" "Rename master to trunk to match name for gvn"

execute "$GVN umdb" "update map database"
