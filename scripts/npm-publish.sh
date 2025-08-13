export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm-publish/token"
mkdir --parents "$(dirname "$NPM_CONFIG_USERCONFIG")"
if [ ! -f "$NPM_CONFIG_USERCONFIG" ]; then
  npm login
fi
npm publish
