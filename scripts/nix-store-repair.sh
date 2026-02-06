#!/usr/bin/env bash
# nix-store-repair: Verify and repair corrupted Nix store paths
#
# Runs nix-store verification with content checking and automatic
# repair of any corrupted store paths found.

nix-store --verify --check-contents --repair
