NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

username=$(gh api user -q '.login')
root_dir="$(ghq root)/github.com/$username"

visited=""

update_flake() {
  node="$1"

  inputs=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$node\".inputs | to_entries | map(.value) | .[]")

  for input in $inputs; do
    owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
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
    echo "Directory $update_dir does not exist, skipping."
    return
  fi

  for visited_dir in $visited; do
    if [ "$visited_dir" = "$update_dir" ]; then
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
  metadata=$(nix flake metadata "$dir" --json)
  update_flake "root"
done
