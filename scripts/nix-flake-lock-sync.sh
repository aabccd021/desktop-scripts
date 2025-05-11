NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
export NIX_CONFIG

root_dir="$(ghq root)/github.com/aabccd021"

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

  if [ "$dir" = "$root_dir/nixos/" ]; then
    echo "$dir: Skipping nixos"
    continue
  fi

  cd "$dir" || exit
  echo "$dir: Updating flake"

  nix flake update nixpkgs --inputs-from ~/ghq/github.com/aabccd021/nixos || true
  nix flake update sops-nix --inputs-from ~/ghq/github.com/aabccd021/nixos || true
  nix flake update treefmt-nix --inputs-from ~/ghq/github.com/aabccd021/nixos || true

  nix-checkpoint || continue

done
