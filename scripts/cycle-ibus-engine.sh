current_engine=$(ibus engine)
next_engine=""
found=false

# Check if we have arguments
if [ $# -eq 0 ]; then
  echo "Error: No engines provided" >&2
  exit 1
fi

# Find the current engine in the list and identify the next one
for engine in "$@"; do
  if [ "$found" = "true" ]; then
    next_engine="$engine"
    break
  fi

  if [ "$current_engine" = "$engine" ]; then
    found=true
  fi
done

# If we didn't find the next engine (either current engine was last in list or not in list),
# use the first one to cycle back to the beginning
if [ -z "$next_engine" ]; then
  next_engine="$1"
fi

# Set the new engine
ibus engine "$next_engine"
