#!/usr/bin/env bash
# hyprctl-cycle-mfact: Cycle through master layout split ratios in Hyprland
#
# Cycles the master factor (mfact) through a list of predefined values.
# Pass the desired mfact values as arguments (e.g., 0.5 0.6 0.7).
# The script finds the current value and sets it to the next one in the list.

# Get current mfact value
current_mfact=$(hyprctl getoption master:mfact -j | jq ".float" || true)

# Find and set next mfact value
target_mfact="$1"
next_found=false
for arg_mfact in "$@"; do
  arg_mfact=$(printf "%.6f" "$arg_mfact")
  if [ "$next_found" = true ]; then
    target_mfact="$arg_mfact"
    break
  fi
  if [ "$current_mfact" = "$arg_mfact" ]; then
    next_found=true
  fi
done

# Apply the new mfact value
hyprctl --quiet dispatch layoutmsg mfact exact "$target_mfact"
hyprctl --quiet keyword master:mfact "$target_mfact"
