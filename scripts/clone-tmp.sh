#!/usr/bin/env bash
# clone-tmp: Clone a local ghq repository into a temporary directory
#
# Usage: clone-tmp <repo> [dest-name]
#
# Clones $HOME/ghq/github.com/<repo> to /tmp (either /tmp/<dest-name>
# or a fresh mktemp directory). Replaces the cloned origin with the
# local repo's remotes, fetches main, copies .env if present, and
# launches a new shell in the destination.

repo="$1"
dest="${2:+/tmp/$2}"
dest="${dest:-$(mktemp -d -p /tmp)}"

local_repo="$HOME/ghq/github.com/$repo"

git clone "$local_repo" "$dest"
cd "$dest" || exit 1
git remote remove origin
git -C "$local_repo" remote | while IFS= read -r name; do
  url=$(git -C "$local_repo" remote get-url "$name")
  git remote add "$name" "$url"
done
git fetch origin main
git switch -C main origin/main

test -f "$local_repo/.env" && cp "$local_repo/.env" "$dest/.env"

exec "$SHELL"
