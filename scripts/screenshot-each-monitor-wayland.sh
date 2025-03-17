if [ -z "$XDG_PICTURES_DIR" ]; then
  echo "XDG_PICTURES_DIR is not set. Exiting."
  exit 1
fi

if [ ! -d "$XDG_PICTURES_DIR" ]; then
  echo "XDG_PICTURES_DIR does not exist. Exiting."
  exit 1
fi

monitor_data=$(wlr-randr --json)

timestamp=$(date +%Y%m%d-%H%M%S)

echo "$monitor_data" | jq -c '.[] | select(.enabled == true)' | while read -r monitor; do
  name=$(echo "$monitor" | jq -r '.name')

  current_mode=$(echo "$monitor" | jq -c '.modes[] | select(.current == true)')
  width=$(echo "$current_mode" | jq -r '.width')
  height=$(echo "$current_mode" | jq -r '.height')
  x_offset=$(echo "$monitor" | jq -r '.position.x')
  y_offset=$(echo "$monitor" | jq -r '.position.y')

  target="$XDG_PICTURES_DIR/screenshot-$timestamp-$name.png"
  echo "Writing screenshot to $target"
  grim -g "${x_offset},${y_offset} ${width}x${height}" "$target"
done
