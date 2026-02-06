#!/usr/bin/env bash
# git-branch-fetch: Fetch a specific remote branch interactively
#
# Lists all remote branches via git ls-remote, allows selection via fzf,
# and fetches the selected branch to a local branch of the same name.

git ls-remote --heads |
  sed 's/.*refs\/heads\/\([a-zA-Z0-9./_-]*\)/\1/' |
  fzf --no-multi |
  xargs -I {} git fetch origin {}:{}
