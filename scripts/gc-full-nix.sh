#!/usr/bin/env bash
# gc-full-nix: Comprehensive Nix garbage collection
#
# Performs a full cleanup of the Nix store including:
# - Upgrading user and root environments
# - Updating channels (if available)
# - Removing all gcroots from nix build commands
# - Running garbage collection for both user and root
# - Optimizing the Nix store to deduplicate files

doas echo starting garbage collection

# Upgrade user environment and collect garbage
nix-env -u --always
nix-collect-garbage -d

# Update channels if nix-channel is available
if command -v nix-channel >/dev/null 2>&1; then
  doas nix-channel --update
fi

# Upgrade root environment
doas nix-env -u --always

# Remove all indirect gcroots (build results from `nix build`)
# See: https://nixos.org/guides/nix-pills/11-garbage-collector#indirect-roots
doas rm /nix/var/nix/gcroots/auto/*

# Root garbage collection and store optimization
doas nix-collect-garbage -d
doas nix-store --optimise
