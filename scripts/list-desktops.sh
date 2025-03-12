# shellcheck disable=SC2153
xdg_data_dirs=$(echo "$XDG_DATA_DIRS" | tr ':' '\n')
for dir in $xdg_data_dirs; do
  if [ -d "$dir/applications" ]; then
    find "$dir/applications" -name '*.desktop'
  fi
done
