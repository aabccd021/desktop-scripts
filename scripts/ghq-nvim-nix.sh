selected_path="${1:-}"

if [ -z "$selected_path" ]; then

  oldfiles=$(
    # cat ~/.local/share/nvim/oldfiles.txt |
    while IFS= read -r file_path; do
      if [ -f "$file_path" ]; then
        printf "%s\n" "$file_path"
      fi
    done <~/.local/share/nvim/oldfiles.txt
  )
  echo "Loading old files from ~/.local/share/nvim/oldfiles.txt"

  ghqdirs=$(ghq list --full-path)

  selected_path=$(printf "%s\n%s" "$oldfiles" "$ghqdirs" |
    grep -v '/quickfix-[0-9]\+$' |
    awk '!seen[$0]++' |
    grep "^$HOME/" |
    sed "s|^$HOME/||" |
    fzf)

  if [ -z "$selected_path" ]; then
    exit 0
  fi

  selected_path="$HOME/$selected_path"
fi

repo_root=""
if [ -d "$selected_path" ]; then
  repo_root="$selected_path"
elif [ -f "$selected_path" ]; then
  file_dir=$(dirname "$selected_path")
  repo_root=$(git -C "$file_dir" rev-parse --show-toplevel || true)
fi

if [ -z "$repo_root" ]; then
  exec "$EDITOR" "$selected_path"
fi

trap 'cd $(pwd)' EXIT
cd "$repo_root" || exit 1

system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
if ! nix build --no-link ".#.devShells.$system.default"; then
  exec "$EDITOR" "$selected_path"
fi

nix develop --command "$EDITOR" "$selected_path" ||
  exec "$EDITOR" "$selected_path"
