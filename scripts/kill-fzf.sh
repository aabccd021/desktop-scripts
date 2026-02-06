#!/usr/bin/env bash
# kill-fzf: Interactive process killer using fzf
#
# Displays a list of running processes with CPU and memory usage,
# allows selection via fzf, and sends SIGKILL to the selected process.

# Get process list and let user select one via fzf
pid=$(
  ps -eo pid,pcpu,pmem,cmd --no-headers |
    fzf --header="Select process to kill" |
    awk '{print $1}'
)

# Exit gracefully if no process was selected
if [ -z "$pid" ]; then
  echo "No process selected"
  exit 0
fi

# Force kill the selected process
kill -9 "$pid"
