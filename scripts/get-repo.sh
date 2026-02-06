#!/usr/bin/env bash
# get-repo: Clone a GitHub repository after showing its size
#
# Fetches repository size from GitHub API, displays it, and prompts
# for confirmation before cloning with ghq in shallow mode.

repo_url="$1"

# Extract owner/repo from GitHub URL
repo_path=$(
  echo "$repo_url" |
    sed 's|https://github.com/||' |
    cut -d '/' -f 1,2
)

# Fetch and display repository size in human-readable format
size=$(
  gh api "/repos/$repo_path" \
    --jq '.size' |
    numfmt --to=iec --from-unit=1024
)

echo "Repository size: $size"
printf "Proceed to clone? [y/n]: "
read -r answer
if [ "$answer" = "y" ]; then
  ghq get --shallow "$repo_url"
else
  echo "Aborted"
fi
