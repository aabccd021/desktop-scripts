NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

username=$(gh api user -q '.login')
root_dir="$(ghq root)/github.com/$username"

visited=""

update_flake() {
  node="$1"
  echo "Processing node: $node"
  echo "$metadata" | jq .

  inputs=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$node\".inputs | to_entries | map(.value) | .[]")
  echo "Inputs for $node: $inputs"

  for input in $inputs; do
    owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
    echo "Processing input: $input, owner: $owner"
    if [ "$owner" = "$username" ]; then
      repo=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.repo")
      update_flake "$repo"
    fi
  done

  if [ "$node" = "root" ]; then
    update_dir="$dir"
  else
    update_dir="$root_dir/$node"
  fi

  if [ ! -d "$update_dir" ]; then
    ghq get "$username/$node"
  fi

  for visited_dir in $visited; do
    if [ "$visited_dir" = "$update_dir" ]; then
      echo "Already visited $update_dir, skipping"
      return
    fi
  done

  cd "$update_dir" || exit 1
  echo "Updating flake in $update_dir"
  nix flake update --commit-lock-file
  nix-checkpoint

  visited="$visited $update_dir"
}

for dir in "$root_dir"/*/; do

  if [ ! -f "$dir/flake.nix" ]; then
    echo "$dir: Skipping non-flake"
    continue
  fi

  echo "Found flake.nix in $dir"

  metadata=$(nix flake metadata "$dir" --json)
  update_flake "root"
done
