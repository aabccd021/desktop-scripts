#!/usr/bin/env bash
# get-my-repo: Clone one of your own GitHub repositories
#
# Lists your GitHub repositories, allows selection via fzf,
# and clones the selected repository using ghq with SSH URL.

# Verify GitHub authentication
gh auth status >/dev/null 2>&1
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "You are not authenticated with GitHub. Please run 'gh auth login'."
  exit "$exit_code"
fi

# List repos and let user select one
selected=$(gh repo list --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | fzf)

# Clone using SSH URL via ghq
ghq get "git@github.com:$selected.git"
