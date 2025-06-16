NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

username=$(gh api user -q '.login')
root_dir="$(ghq root)/github.com/$username"

visited=""

update_dirs=""

update_flake() {
  node="$1"

  inputs=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$node\".inputs | to_entries | map(.value) | .[]")

  for input in $inputs; do
    owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
    if [ "$owner" = "$username" ]; then
      repo=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.repo")
      update_dirs="$root_dir/$repo $update_dirs"
      update_flake "$input"
    fi
  done
}

for dir in "$root_dir"/*/; do

  if [ ! -f "$dir/flake.nix" ]; then
    continue
  fi

  update_dirs="$dir $update_dirs"
  metadata=$(nix flake metadata "$dir" --json)
  update_flake "root"
done

for dir in $update_dirs; do
  should_skip=false
  for visited_dir in $visited; do
    if [ "$visited_dir" = "$dir" ]; then
      should_skip=true
      break
    fi
  done

  if [ "$should_skip" = true ]; then
    echo "Skipping already visited directory: $dir"
    continue
  fi

  if [ ! -d "$dir" ]; then
    ghq get "$dir"
  fi

  cd "$dir" || exit 1
  echo "Updating flake in $dir"
  nix flake update --commit-lock-file
  nix-checkpoint
  visited="$visited $dir"
done
