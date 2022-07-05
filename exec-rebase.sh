#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PARENT_COMMIT_REF=""
EXEC_COMMAND=""

# So, the way to do this is
# checkout formatting file from branch
# then apply formatting command
# amend commit the entire thing
# note the commit hash, push into queue
# then reset to HEAD~
# repeat until you get to root of branch
# then cherry-pick until queue empty
# now rebase onto target

optstring=':p:x:'
while getopts ${optstring} arg; do
  case ${arg} in
    x) 
      EXEC_COMMAND="${OPTARG}" 
      ;;
    p) 
      PARENT_COMMIT_REF="${OPTARG}" 
      ;;
    :)
      echo "Terminating, missing required options..."
      exit 1
      ;;
    ?)
      echo "Terminating, unknown option..."
      exit 1
      ;;
  esac
done

if [[ $((OPTIND-1)) -ne 4 ]]; then
  echo "wrong number of options"
  exit 1
fi

#CUR_HEAD_HASH=$(git rev-parse HEAD)
PARENT_COMMIT_HASH=$(git rev-parse "$PARENT_COMMIT_REF")
declare -r EXEC_COMMAND PARENT_COMMIT_HASH
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


git checkout -b LINT_REBASE_HEAD
for commit_index in "${!EDITED_COMMIT_HASHES[@]}"; do
  git cherry-pick "${EDITED_COMMIT_HASHES[-commit_index-1]}"
done

#git reset --soft "$CUR_HEAD_HASH"