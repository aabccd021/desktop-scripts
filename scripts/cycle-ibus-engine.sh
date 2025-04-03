current_engine=$(ibus engine || true)
if [ -z "$current_engine" ]; then
  ibus engine "${2:-$1}"
  exit 0
fi

next_engine="$1"
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

echo "Switching IBus engine from '$current_engine' to '$next_engine'"
ibus engine "$next_engine"
