#!/usr/bin/env bash
# list-desktops: List all .desktop application files
#
# Searches through all XDG data directories and outputs paths
# to all .desktop files found in applications subdirectories.

# shellcheck disable=SC2153
xdg_data_dirs=$(echo "$XDG_DATA_DIRS" | tr ':' '\n')

for dir in $xdg_data_dirs; do
  if [ -d "$dir/applications" ]; then
    find "$dir/applications" -name '*.desktop'
  fi
done
