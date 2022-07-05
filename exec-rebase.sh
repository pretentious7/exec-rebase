#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# So, the way to do this is
# checkout formatting file from branch
# then apply formatting command
# amend commit the entire thing
# note the commit hash, push into queue
# then reset to HEAD~
# repeat until you get to root of branch
# then cherry-pick until queue empty
# now rebase onto target
PARENT_COMMIT_REF=${1:-}
if [[ -z "$PARENT_COMMIT_REF" ]]; then
  echo "Parent commit ref must be defined"
  exit 1
fi

TEMP=$(getopt -o 'x:' -- "$@")
if [ $? -ne 0 ]; then
  echo "Terminating! Not all required command line arguments"
fi
eval set -- "$TEMP"
unset TEMP

EXEC_COMMAND="$2"
CUR_HEAD_HASH=$(git rev-parse HEAD)
PARENT_COMMIT_HASH=$(git rev-parse "$PARENT_COMMIT_REF")
declare -r EXEC_COMMAND CUR_HEAD_HASH PARENT_COMMIT_HASH
#TODO: write trap to handle if invalid ref
#TODO: ensure no detached head

EDITED_COMMIT_HASHES=()
while [[ $(git rev-parse HEAD) != "$PARENT_COMMIT_HASH" ]]; do
  eval "$EXEC_COMMAND"
  #TODO: ensure this happens in repo root
  git add .
  git commit --amend --no-edit
  EDITED_COMMIT_HASHES+=("$(git rev-parse HEAD)")
  git checkout HEAD^
done  


#shopt -s lastpipe
#printf "%s " "${EDITED_COMMIT_HASHES[@]}" | tac | read -r -a REV_EDITED_COMMIT_HASHES
#git checkout -b LINT_REBASE_HEAD
for commit_index in "${!EDITED_COMMIT_HASHES[@]}"; do
  #git cherry-pick "$commit_hash"
  echo "${commit_index}"
  echo "${EDITED_COMMIT_HASHES[-commit_index]}"
done
echo "$PARENT_COMMIT_REF"

#git reset --soft "$CUR_HEAD_HASH"