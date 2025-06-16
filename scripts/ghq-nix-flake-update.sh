NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

username=$(gh api user -q '.login')
root_dir="$(ghq root)/github.com/$username"

tmpfile=$(mktemp)

update_flake() {
  node="$1"
  inputs=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$node\".inputs | to_entries | map(.value) | .[]")
  for input in $inputs; do
    owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
    if [ "$owner" = "$username" ]; then
      repo=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.repo")
      echo "$root_dir/$repo/" >>"$tmpfile"
      update_flake "$input"
    fi
  done
}

for dir in "$root_dir"/*/; do

  if [ ! -f "$dir/flake.nix" ]; then
    continue
  fi

  metadata=$(nix flake metadata "$dir" --json)
  echo "$dir" >>"$tmpfile"
  update_flake "root"
done

update_dirs=$(tac "$tmpfile" | awk '!seen[$0]++')

for dir in $update_dirs; do

  if [ ! -d "$dir" ]; then
    ghq get "$dir"
  fi

  cd "$dir" || exit 1
  echo "Updating flake in $dir"
  nix flake update --commit-lock-file
  nix-checkpoint
done
