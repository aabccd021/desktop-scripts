if [ -z "$XDG_PICTURES_DIR" ]; then
  echo "XDG_PICTURES_DIR is not set. Exiting."
  exit 1
fi

if [ ! -d "$XDG_PICTURES_DIR" ]; then
  echo "XDG_PICTURES_DIR does not exist. Exiting."
  exit 1
fi

monitors=$(
  xrandr --listactivemonitors |
    grep -v "Monitors" |
    sed 's/.*\s\([^ ]*\)$/\1/'
)
if [ -z "$monitors" ]; then
  echo "No monitors detected. Exiting."
  exit 1
fi

geometries=$(
  xrandr |
    grep " connected " |
    sed -r 's/^([^ ]+).*\b([0-9]+x[0-9]+\+[0-9]+\+[0-9]+)\b.*/\1 \2/'
)
timestamp=$(date +%Y%m%d-%H%M%S)

while IFS= read -r line; do
  monitor=$(echo "$line" | cut -d' ' -f1)
  geometry=$(echo "$line" | cut -d' ' -f2)
  maim -g "$geometry" "$XDG_PICTURES_DIR/screenshot-$timestamp-$monitor.png"
done <<EOF
$geometries
EOF
