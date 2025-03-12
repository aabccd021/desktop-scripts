target=$(kdeconnect-cli --list-available --id-only)
if [ -z "$target" ]; then
  echo "No device found"
  exit 1
fi

kdeconnect-cli --device "$target" --share "$@"
