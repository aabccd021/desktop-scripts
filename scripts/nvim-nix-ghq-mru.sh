selected_path="${1:-}"

if [ -z "$selected_path" ]; then
  oldfiles=$("$EDITOR" --headless -u NONE -c 'oldfiles | q' 2>&1 |
    tr -d '\r' |
    cut -d ' ' -f 2-)

  ghqdirs=$(ghq list --full-path)

  selected_path=$(printf "%s\n%s" "$oldfiles" "$ghqdirs" |
    awk '!seen[$0]++' |
    grep "^$HOME/" |
    sed "s|^$HOME/||" |
    fzf)

  if [ -z "$selected_path" ]; then
    exit 0
  fi

  selected_path="$HOME/$selected_path"
fi

if [ -d "$selected_path" ]; then
  repo_root="$selected_path"
elif [ -f "$selected_path" ]; then
  file_dir=$(dirname "$selected_path")
  repo_root=$(git -C "$file_dir" rev-parse --show-toplevel ||
    echo "$file_dir")
fi

trap 'cd $(pwd)' EXIT
cd "$repo_root" || exit 1

system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
devShell=$(nix flake show --json |
  jq ".devShells[\"$system\"][\"default\"]" ||
  true)

if [ -z "$devShell" ]; then
  exec "$EDITOR" "$selected_path"
fi

if ! nix build --no-link ".#.devShells.$system.default"; then
  exec "$EDITOR" "$selected_path"
fi

exec nix develop --command "$EDITOR" "$selected_path" ||
  exec "$EDITOR" "$selected_path"
