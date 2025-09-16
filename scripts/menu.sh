#!/bin/sh

fifo=$(mktemp -u)
mkfifo "$fifo"
trap 'rm -f "$fifo"' EXIT

(
  IFS=:
  for dir in $PATH; do
    [ -d "$dir" ] || continue
    find "$dir" -maxdepth 1 -type f -perm -111 2>/dev/null
  done | sort -u > "$fifo"
) &

chosen_cmd=$(fzf < "$fifo")

if [ -n "$selection" ]; then
  systemd-run --user "$selection"
elif [ -n "$query" ]; then
  systemd-run --user $query
fi
