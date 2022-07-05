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

PARENT_COMMIT_HASH=$(git rev-parse "$PARENT_COMMIT_REF")
#TODO: write trap to handle if invalid ref


while [[ $(git rev-parse HEAD) != "$PARENT_COMMIT_HASH" ]]; do
  echo "yay"
done  
#git checkout HEAD^

#echo "$PARENT_COMMIT_REF"