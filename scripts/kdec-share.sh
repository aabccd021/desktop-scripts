#!/usr/bin/env bash
# kdec-share: Share files to connected KDE Connect device
#
# Finds the first available KDE Connect device and shares
# the specified files to it.

# Get the first available device ID
target=$(kdeconnect-cli --list-available --id-only)

if [ -z "$target" ]; then
  echo "No device found"
  exit 1
fi

# Share files to the device
kdeconnect-cli --device "$target" --share "$@"
