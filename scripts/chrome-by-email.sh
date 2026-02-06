#!/usr/bin/env bash

email="$1"
if [ -z "$email" ]; then
  echo "Usage: chrome-profile <email>"
  exit 1
fi

profile_dir=$(jq -r --arg email "$email" \
  '.profile.info_cache | to_entries[] | select(.value.user_name == $email) | .key' \
  "$HOME/.config/google-chrome/Local State")

if [ -z "$profile_dir" ]; then
  echo "Profile not found for email: $email"
  exit 1
fi

exec google-chrome-stable --profile-directory="$profile_dir"
