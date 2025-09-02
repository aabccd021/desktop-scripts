current_mfact=$(hyprctl getoption master:mfact -j | jq ".float" || true)

target_mfact="$1"
next_found=false
for arg_mfact in "$@"; do
  arg_mfact=$(printf "%.6f" "$arg_mfact")
  if [ "$next_found" = true ]; then
    target_mfact="$arg_mfact"
    break
  fi
  if [ "$current_mfact" = "$arg_mfact" ]; then
    next_found=true
  fi
done

hyprctl --quiet dispatch layoutmsg mfact exact "$target_mfact"
hyprctl --quiet keyword master:mfact "$target_mfact"
