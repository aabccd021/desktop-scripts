#!/usr/bin/env bash
# ghq-nvim-nix: Open projects in editor with Nix devShell support
#
# Interactive project opener that:
# - Shows recent files from neovim oldfiles and ghq repositories
# - Attempts to build and enter the project's Nix devShell
# - Falls back to opening without devShell if build fails
# - Maintains a history of opened files for quick access

selected_path="${1:-}"

if [ -z "$selected_path" ]; then
  # Setup oldfiles log
  logfile="$XDG_DATA_HOME/nvim/oldfiles.txt"
  if [ ! -f "$logfile" ]; then
    mkdir -p "$(dirname "$logfile")"
    touch "$logfile"
  fi

  # Cleanup logfile: remove non-existent files, dedupe, keep last 1000
  tmpfile="$(mktemp)"
  while IFS= read -r line; do
    if [ -f "$line" ]; then
      echo "$line" >>"$tmpfile"
    fi
  done <"$logfile"
  tac "$tmpfile" | awk '!seen[$0]++' | tac | tail -n 1000 >"$logfile"

  # Combine oldfiles and ghq directories for selection
  oldfiles=$(tac "$logfile")
  ghqdirs=$(ghq list --full-path)

  selected_path=$(
    printf "%s\n%s" "$oldfiles" "$ghqdirs" |
      sed "s|^$HOME/|~/|" |
      fzf |
      sed "s|^~/|$HOME/|"
  )

  if [ -z "$selected_path" ]; then
    exit 0
  fi
fi

# Determine repository root
repo_root=""
if [ -d "$selected_path" ]; then
  repo_root="$selected_path"
elif [ -f "$selected_path" ]; then
  file_dir=$(dirname "$selected_path")
  repo_root=$(git -C "$file_dir" rev-parse --show-toplevel || true)
fi

# If not in a git repo, just open the file
if [ -z "$repo_root" ]; then
  exec "$EDITOR" "$selected_path"
fi

# Save current directory and change to repo root
trap 'cd $(pwd)' EXIT
cd "$repo_root" || exit 1

# Try to build the devShell
system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
if ! nix build --no-link ".#.devShells.$system.default"; then
  # Build failed - try to open README if selecting a directory
  readme_file=$(
    find "$selected_path" -maxdepth 1 -type f \( -iname "readme*" -o -iname "README*" \) |
      head -n 1 ||
      true
  )
  if [ -n "$readme_file" ]; then
    selected_path=$(realpath "$readme_file")
  fi
  exec "$EDITOR" "$selected_path"
fi

# Default to flake.nix if directory was selected
if [ "$selected_path" = "$repo_root" ]; then
  selected_path="$repo_root/flake.nix"
fi

# Open in devShell, falling back to regular editor
nix develop --command "$EDITOR" "$selected_path" ||
  exec "$EDITOR" "$selected_path"
