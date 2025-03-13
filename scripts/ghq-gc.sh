repos=$(ghq list)
root=$(ghq root)

for repo in $repos; do
  cd "$root/$repo" || exit 1

  branch_count=$(git branch | wc -l)
  if [ "$branch_count" -ne 1 ]; then
    echo "$repo: Repository has $branch_count local branches (expected: 1)"
    continue
  fi

  if ! git diff --quiet HEAD; then
    echo "$repo: Repository has uncommitted changes"
    continue
  fi

  if ! git diff --staged --quiet; then
    echo "$repo: Repository has staged but uncommitted changes"
    continue
  fi

  unpushed_commits=$(git log '@{u}..' 2>/dev/null)
  if [ -n "$unpushed_commits" ]; then
    echo "$repo: Repository has unpushed commits"
    continue
  fi

  last_commit_timestamp=$(git log -1 --format=%ct)
  current_timestamp=$(date +%s)
  two_weeks_seconds=$((14 * 24 * 60 * 60)) # 14 days in seconds

  if [ $((current_timestamp - last_commit_timestamp)) -lt "$two_weeks_seconds" ]; then
    continue
  fi

  rm -rf "${root:?}/${repo:?}"
  echo "$repo: Removed"

done
