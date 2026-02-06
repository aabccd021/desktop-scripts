#!/usr/bin/env bash
# npm-publish: Publish npm package with XDG-compliant config
#
# Uses a separate npm config file in XDG_CONFIG_HOME to store
# npm credentials, prompting for login if not already authenticated.

# Use XDG-compliant config location for npm token
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm-publish/token"

# Ensure config directory exists
mkdir --parents "$(dirname "$NPM_CONFIG_USERCONFIG")"

# Login if not authenticated
if [ ! -f "$NPM_CONFIG_USERCONFIG" ]; then
  npm login
fi

# Publish the package
npm publish
