#!/usr/bin/env bash
# clone-pr: Clone a GitHub repository at a PR's branch
#
# Usage: clone-pr <repo> <pr-number>

repo="$1"
pr_number="$2"

if [ -z "$repo" ] || [ -z "$pr_number" ]; then
  echo "Usage: clone-pr <repo> <pr-number>"
  exit 1
fi

branch=$(gh pr view "$pr_number" --repo "$repo" --json headRefName -q .headRefName)

mkdir -p "$HOME/pr"

git clone "git@github.com:$repo.git" "$HOME/pr/$repo/$pr_number" --branch "$branch" --single-branch

cd "$HOME/pr/$repo/$pr_number" || exit
claude --dangerously-skip-permissions
