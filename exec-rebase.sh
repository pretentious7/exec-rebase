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

CUR_HEAD_HASH=$(git rev-parse HEAD)
declare -r CUR_HEAD_HASH
PARENT_COMMIT_HASH=$(git rev-parse "$PARENT_COMMIT_REF")
declare -r PARENT_COMMIT_HASH
#TODO: write trap to handle if invalid ref


while [[ $(git rev-parse HEAD) != "$PARENT_COMMIT_HASH" ]]; do
  git checkout HEAD^
  echo "HELLO"
  git status
done  
#git checkout HEAD^

#echo "$PARENT_COMMIT_REF"

git reset --soft "$CUR_HEAD_HASH"