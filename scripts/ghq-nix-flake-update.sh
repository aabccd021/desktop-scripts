update_externals=false

while [ $# -gt 0 ]; do
  case "$1" in
  --update-externals)
    update_externals=true
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
  shift
done

NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

username=$(gh api user -q '.login')
root_dir="$(ghq root)/github.com/$username"

tmpfile=$(mktemp)
tmpdir=$(mktemp -d)

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

  dirbase=$(basename "$dir")
  metadata=$(nix flake metadata "$dir" --json)
  echo "$metadata" >"$tmpdir/$dirbase.json"
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
  dirbase=$(basename "$dir")
  metadata=$(cat "$tmpdir/$dirbase.json")
  inputs=$(echo "$metadata" | jq --raw-output '.locks.nodes."root".inputs | to_entries | map(.key) | .[]')
  for input in $inputs; do
    owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
    if [ "$owner" = "$username" ] || [ "$update_externals" = true ]; then
      nix flake update "$input" --commit-lock-file
    fi
  done
  nix-checkpoint
done
