#!/usr/bin/env bash
# chrome-by-email: Open Google Chrome with a specific profile by email
#
# Looks up the Chrome profile directory associated with a given email
# address from Chrome's Local State file and launches Chrome with that profile.

email="$1"

if [ -z "$email" ]; then
  echo "Usage: chrome-by-email <email>"
  exit 1
fi

# Find profile directory matching the email from Chrome's Local State
profile_dir=$(jq -r --arg email "$email" \
  '.profile.info_cache | to_entries[] | select(.value.user_name == $email) | .key' \
  "$HOME/.config/google-chrome/Local State")

if [ -z "$profile_dir" ]; then
  echo "Profile not found for email: $email"
  exit 1
fi

# Launch Chrome with the matched profile
exec google-chrome-stable --profile-directory="$profile_dir"
