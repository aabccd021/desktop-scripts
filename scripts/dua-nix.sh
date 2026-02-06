#!/usr/bin/env bash
# dua-nix: Interactive disk usage analyzer for Nix store
#
# Opens dua (disk usage analyzer) in interactive mode for /nix/store
# with options to count hard links and show apparent size.

dua --count-hard-links --apparent-size interactive /nix/store
