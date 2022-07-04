#!/usr/bin/env bash

# So, the way to do this is
# checkout formatting file from branch
# then apply formatting command
# amend commit the entire thing
# note the commit hash, push into queue
# then reset to HEAD~
# repeat until you get to root of branch
# then cherry-pick until queue empty
# now rebase onto target
