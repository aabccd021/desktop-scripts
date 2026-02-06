#!/usr/bin/env bash
# git-rebase-easy: Interactive rebase helper with automatic merge-base detection
#
# Simplifies rebasing by allowing branch selection via fzf, automatically
# fetching remote branches if needed, and finding the correct merge-base
# even in shallow clones by deepening the repository as needed.

target_branch="$1"

# If no branch specified, let user select from all branches via fzf
if [ -z "$target_branch" ]; then
  target_branch=$(
    git branch --all --no-color --sort=-committerdate |
      grep -v HEAD |
      sed 's/.* //' |
      fzf --no-multi
  )
fi

# If a remote branch (e.g., origin/main) was selected, fetch it first
num_slash=$(echo "$target_branch" | grep -c '/')
if [ "$num_slash" -eq 1 ]; then
  echo "Remote branch selected as target. Fetching the remote branch"
  remote=$(echo "$target_branch" | cut -d '/' -f 1)
  branch=$(echo "$target_branch" | cut -d '/' -f 2)
  git fetch "$remote" "$branch"
fi

# Find merge-base, deepening shallow clone if necessary
merge_base=""
while [ -z "$merge_base" ]; do
  merge_base=$(git merge-base HEAD "$target_branch")
  git fetch --deepen=10
done

# Perform the rebase
git rebase --onto "$target_branch" "$merge_base"
