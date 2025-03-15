if [ -z "$XDG_PICTURES_DIR" ]; then
  echo "XDG_PICTURES_DIR is not set. Exiting."
  exit 1
fi

if [ ! -d "$XDG_PICTURES_DIR" ]; then
  echo "XDG_PICTURES_DIR does not exist. Exiting."
  exit 1
fi

if ! monitor_data=$(xrandr | jc --xrandr); then
  echo "Failed to get monitor information. Exiting."
  exit 1
fi

connected_count=$(echo "$monitor_data" | jq '.screens[0].devices | map(select(.is_connected == true)) | length')
if [ "$connected_count" -eq 0 ]; then
  echo "No monitors detected. Exiting."
  exit 1
fi

timestamp=$(date +%Y%m%d-%H%M%S)

echo "$monitor_data" |
  jq -c '.screens[0].devices[] | select(.is_connected == true)' |
  while read -r monitor; do

    name=$(echo "$monitor" | jq -r '.device_name')
    width=$(echo "$monitor" | jq -r '.resolution_width')
    height=$(echo "$monitor" | jq -r '.resolution_height')
    x_offset=$(echo "$monitor" | jq -r '.offset_width')
    y_offset=$(echo "$monitor" | jq -r '.offset_height')

    geometry="${width}x${height}+${x_offset}+${y_offset}"

    target="$XDG_PICTURES_DIR/screenshot-$timestamp-$name.png"
    echo "Writing screenshot to $target"
    maim -g "$geometry" "$target"
  done
