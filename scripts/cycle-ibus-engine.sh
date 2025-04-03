current_engine=$(ibus engine || true)
next_engine=""
found=false

for engine in "$@"; do
  if [ "$found" = true ]; then
    next_engine="$engine"
    break
  fi

  if [ "$current_engine" = "$engine" ]; then
    found=true
  fi
done

if [ -z "$next_engine" ]; then
  if [ "$found" = true ]; then
    next_engine="$1"
  else
    next_engine="${2:-$1}"
  fi
fi

echo "Switching IBus engine from '$current_engine' to '$next_engine'"
ibus engine "$next_engine"
