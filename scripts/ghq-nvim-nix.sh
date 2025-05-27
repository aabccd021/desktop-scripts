selected_path="${1:-}"

if [ -z "$selected_path" ]; then
  logfile="$XDG_DATA_HOME/nvim/oldfiles.txt"

  # cleanup logfile
  tmpfile="$(mktemp)"
  while IFS= read -r line; do
    if [ -f "$line" ]; then
      echo "$line" >>"$tmpfile"
    fi
  done <"$logfile"
  tac "$tmpfile" | awk '!seen[$0]++' | tac | tail -n 1000 >"$logfile"

  oldfiles=$(tac "$logfile")
  ghqdirs=$(ghq list --full-path)

  selected_path=$(printf "%s\n%s" "$oldfiles" "$ghqdirs" | grep "^$HOME/" | sed "s|^$HOME/||" | fzf)

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
