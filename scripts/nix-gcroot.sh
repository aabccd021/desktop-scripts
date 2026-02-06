#!/usr/bin/env bash
# nix-gcroot: Create a garbage collection root for a flake output
#
# Builds the specified flake reference and creates a symlink in
# the user's cache directory to prevent garbage collection.

input="$1"

# Ensure the gcroots directory exists
mkdir --parents "$XDG_CACHE_HOME/nix-gcroots"

# Build and create a gcroot symlink
nix build "$input" --out-link "$XDG_CACHE_HOME/nix-gcroots/$input"
