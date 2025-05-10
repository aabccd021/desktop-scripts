selected_path="${1:-}"

if [ -z "$selected_path" ]; then
  oldfiles=$("$EDITOR" --headless -u NONE -c 'oldfiles | q' 2>&1 | tr -d '\r' | cut -d ' ' -f 2-)
  ghqdirs=$(ghq list --full-path)

  selected_path=$(printf "%s\n%s" "$oldfiles" "$ghqdirs" | awk '!seen[$0]++' | grep "^$HOME/" | sed "s|^$HOME/||" | fzf)
  if [ -z "$selected_path" ]; then
    exit 0
  fi

  selected_path="$HOME/$selected_path"
fi

if [ -d "$selected_path" ]; then
  repo_root="$selected_path"
elif [ -f "$selected_path" ]; then
  file_dir=$(dirname "$selected_path")
  repo_root=$(git -C "$file_dir" rev-parse --show-toplevel 2>/dev/null || echo "$file_dir")
fi

nix develop "$repo_root" --command "$EDITOR" "$selected_path" || "$EDITOR" "$selected_path"
