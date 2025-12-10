update_externals=false
inputs_from=""

while [ $# -gt 0 ]; do
  case "$1" in
  --update-externals)
    update_externals=true
    ;;
  --inputs-from)
    inputs_from="$2"
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
  shift
done

NIX_CONFIG='
  access-tokens = github.com='"$(gh auth token)"'
  substituters = https://mirrors.ustc.edu.cn/nix-channels/store?priority=39 https://cache.nixos.org https://nix-community.cachix.org
'
export NIX_CONFIG

username=$(gh api user -q '.login')
root_dir="$(ghq root)/github.com/$username"

tmpfile=$(mktemp)
tmpdir=$(mktemp -d)

update_flake() {
  node="$1"
  inputs=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$node\".inputs | to_entries | map(.value) | .[]")
  for input in $inputs; do
    flake=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".flake")
    if [ "$flake" = "false" ]; then
      continue
    fi
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
    continue
  fi

  cd "$root_dir/$repo" || exit 1

  if [ ! -f "$tmpdir/$repo.json" ]; then
    continue
  fi

  metadata=$(cat "$tmpdir/$repo.json")
  inputs=$(echo "$metadata" | jq --raw-output '.locks.nodes."root".inputs | to_entries | map(.key) | .[]')

  checkpoint_ran=false
  updated_inputs=""

  if [ "$update_externals" = false ]; then
    for input in $inputs; do
      owner=$(echo "$metadata" | jq --raw-output ".locks.nodes.\"$input\".original.owner")
      if [ "$owner" = "$username" ]; then
        updated_inputs="$updated_inputs $input"
      fi
    done
  else
    updated_inputs="$inputs"
  fi

  echo "Updating inputs:"
  for input in $updated_inputs; do
    echo "- $input"
  done
  if [ -z "$inputs_from" ]; then
    # shellcheck disable=SC2086
    nix flake update $updated_inputs
  else
    # shellcheck disable=SC2086
    nix flake update $updated_inputs --inputs-from "$inputs_from"
  fi

  git add flake.lock
  if [ -n "$(git status --porcelain)" ]; then
    git commit -m "Update flake inputs: $updated_inputs"
    nix-checkpoint
    checkpoint_ran=true
  fi

  if [ "$checkpoint_ran" = false ]; then
    nix-checkpoint
  fi
done
