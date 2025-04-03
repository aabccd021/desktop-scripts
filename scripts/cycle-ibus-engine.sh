current_engine=$(ibus engine)
next_engine=""
found=false

for engine in "$@"; do
  if [ "$found" = "true" ]; then
    next_engine="$engine"
    break
  fi

  if [ "$current_engine" = "$engine" ]; then
    found=true
  fi
done

if [ -z "$next_engine" ]; then
  next_engine="${2:-$1}"
fi

ibus engine "$next_engine"
