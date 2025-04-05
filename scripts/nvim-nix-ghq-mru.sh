selected_file="${1:-}"

if [ -z "$selected_file" ]; then
  oldfiles=$("$EDITOR" --headless -u NONE -c 'oldfiles | q' 2>&1 | tr -d '\r' | cut -d ' ' -f 2-)
  ghqdirs=$(ghq list --full-path)
  allfiles=$(printf "%s\n%s" "$oldfiles" "$ghqdirs")
  selected_file=$(echo "$allfiles" | grep "^$HOME/" | sed "s|^$HOME/||" | fzf)

  if [ -z "$selected_file" ]; then
    exit 0
  fi

  selected_file="$HOME/$selected_file"
fi

file_dir=$(dirname "$selected_file")

repo_root=$(git -C "$file_dir" rev-parse --show-toplevel 2>/dev/null || echo "$file_dir")

nix develop "$repo_root" --command "$EDITOR" "$selected_file" 2>/dev/null || "$EDITOR" "$selected_file"
