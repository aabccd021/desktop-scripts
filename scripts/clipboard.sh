if [ -n "$WAYLAND_DISPLAY" ]; then
  exec wl-copy
  exit
fi
exec xclip -selection clipboard >/dev/null 2>&1
