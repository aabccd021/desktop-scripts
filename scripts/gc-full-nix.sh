#!/usr/bin/env bash
# gc-full-nix: Comprehensive Nix garbage collection
#
# Performs a full cleanup of the Nix store including:
# - Upgrading user and root environments
# - Updating channels (if available)
# - Removing all gcroots from nix build commands, with --rm-gcroots only
# - Running garbage collection for both user and root
# - Optimizing the Nix store to deduplicate files
#
# Exactly one of --rm-gcroots and --keep-gcroots is required, and there is no
# default. Clearing /nix/var/nix/gcroots/auto unroots every `nix build
# --out-link` result and every out-of-store profile, so flake input sources and
# devShell profiles rooted there are collected with everything else and the next
# evaluation refetches or rebuilds them. Which of those two outcomes is wanted
# depends on the run, so the caller says.

usage() {
  cat <<'EOF'
Usage: gc-full-nix (--rm-gcroots | --keep-gcroots)

  --rm-gcroots    Delete every indirect gcroot under /nix/var/nix/gcroots/auto
                  before collecting, so `nix build --out-link` results and
                  out-of-store profiles stop being roots and their closures are
                  collected too.
  --keep-gcroots  Leave the indirect gcroots in place, collecting only what
                  nothing roots.
EOF
}

if [ "$#" -ne 1 ]; then
  usage >&2
  exit 1
fi

case "$1" in
--rm-gcroots) rm_gcroots=true ;;
--keep-gcroots) rm_gcroots=false ;;
*)
  echo "gc-full-nix: unknown argument: $1" >&2
  usage >&2
  exit 1
  ;;
esac

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

if [ "$rm_gcroots" = true ]; then
  # Remove all indirect gcroots (build results from `nix build`)
  # See: https://nixos.org/guides/nix-pills/11-garbage-collector#indirect-roots
  doas rm /nix/var/nix/gcroots/auto/*
fi

# Root garbage collection and store optimization
doas nix-collect-garbage -d
doas nix-store --optimise
