NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

username=$(gh api user -q '.login')

root_dir="$(ghq root)/github.com/$username"

for dir in "$root_dir"/*/; do

  if [ ! -f "$dir/flake.nix" ]; then
    echo "$dir: Skipping non-flake"
    continue
  fi

  # continue if there is unstaged changes
  if ! git -C "$dir" diff --quiet; then
    echo "$dir: Skipping unstaged changes"
    continue
  fi

  cd "$dir" || exit

  echo ""
  echo "$dir: Updating flake"

  last_commit=$(git rev-parse HEAD)

  nix flake update --commit-lock-file

  last_commit_after_update=$(git rev-parse HEAD)

  if [ "$last_commit" = "$last_commit_after_update" ]; then
    echo "$dir: No changes"
    continue
  fi

  nix-checkpoint || continue

done
