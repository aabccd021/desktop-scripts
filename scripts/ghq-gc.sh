#!/usr/bin/env bash
# ghq-gc: Garbage collect old ghq repositories
#
# Removes repositories managed by ghq that meet all criteria:
# - Only one local branch (no feature branches)
# - No uncommitted or staged changes
# - No unpushed commits
# - Last commit older than 2 weeks
#
# Helps keep the ghq directory clean by removing stale clones.

repos=$(ghq list)
root=$(ghq root)

for repo in $repos; do
  cd "$root/$repo" || exit 1

  # Skip if multiple local branches exist
  branch_count=$(git branch | wc -l)
  if [ "$branch_count" -ne 1 ]; then
    echo "$repo: Repository has $branch_count local branches (expected: 1)"
    continue
  fi

  # Skip if there are uncommitted changes
  if ! git diff --quiet HEAD; then
    echo "$repo: Repository has uncommitted changes"
    continue
  fi

  # Skip if there are staged but uncommitted changes
  if ! git diff --staged --quiet; then
    echo "$repo: Repository has staged but uncommitted changes"
    continue
  fi

  # Skip if there are unpushed commits
  unpushed_commits=$(git log '@{u}..' 2>/dev/null)
  if [ -n "$unpushed_commits" ]; then
    echo "$repo: Repository has unpushed commits"
    continue
  fi

  # Skip if last commit is less than 2 weeks old
  last_commit_timestamp=$(git log -1 --format=%ct)
  current_timestamp=$(date +%s)
  two_weeks_seconds=$((14 * 24 * 60 * 60))

  if [ $((current_timestamp - last_commit_timestamp)) -lt "$two_weeks_seconds" ]; then
    continue
  fi

  # Safe to remove
  rm -rf "${root:?}/${repo:?}"
  echo "$repo: Removed"

done
