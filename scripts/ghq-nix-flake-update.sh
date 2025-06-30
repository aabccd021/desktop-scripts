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
      echo "$repo" >>"$tmpfile"
      update_flake "$input"
    fi
  done
}

for dir in "$root_dir"/*/; do
  repo=$(basename "$dir")

  if [ ! -f "$root_dir/$repo/flake.nix" ]; then
    continue
  fi

  echo "Parsing inputs of $repo"
  metadata=$(nix flake metadata "$root_dir/$repo" --json)
  echo "$metadata" >"$tmpdir/$repo.json"
  echo "$repo" >>"$tmpfile"
  update_flake "root"
done

update_dirs=$(tac "$tmpfile" | awk '!seen[$0]++')

for repo in $update_dirs; do
  echo ""
  echo "Updating repository $repo"

  if [ ! -d "$root_dir/$repo" ]; then
    set -x
    ghq get "github.com/$username/$repo"
    set +x
  fi

  cd "$root_dir/$repo" || exit 1

  metadata=$(cat "$tmpdir/$repo.json")
  inputs=$(echo "$metadata" | jq --raw-output '.locks.nodes."root".inputs | to_entries | map(.key) | .[]')

  checkpoint_ran=false

  if [ "$update_externals" = true ]; then
    echo "Updating input nixpkgs"
    nix flake update nixpkgs
    git add flake.lock
    if [ -n "$(git status --porcelain)" ]; then
      git commit -m "Update flake input $input"
      nix-checkpoint
      checkpoint_ran=true
    fi
  fi

  user_inputs=""
  for input in $inputs; do
    owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
    if [ "$owner" = "$username" ]; then
      user_inputs="$user_inputs $input"
    fi
  done

  if [ -n "$user_inputs" ]; then
    echo "Updating user Inputs inputs: $user_inputs"
    # shellcheck disable=SC2086
    nix flake update $user_inputs
    git add flake.lock
    if [ -n "$(git status --porcelain)" ]; then
      git commit -m "Update flake inputs"
      nix-checkpoint
      checkpoint_ran=true
    fi
  fi

  if [ "$update_externals" = true ]; then
    echo "Updating all inputs"
    nix flake update
    git add flake.lock
    if [ -n "$(git status --porcelain)" ]; then
      git commit -m "Update external flake inputs"
      nix-checkpoint
      checkpoint_ran=true
    fi
  fi

  if [ "$checkpoint_ran" = false ]; then
    nix-checkpoint
  fi
done
