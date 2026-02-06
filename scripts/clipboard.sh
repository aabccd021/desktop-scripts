#!/usr/bin/env bash
# clipboard: Cross-platform clipboard copy utility
#
# Automatically detects Wayland or X11 environment and uses the
# appropriate clipboard tool (wl-copy for Wayland, xclip for X11).
# Reads from stdin and copies to system clipboard.

if [ -n "$WAYLAND_DISPLAY" ]; then
  # Wayland environment detected
  exec wl-copy
  exit
fi

# X11 environment (fallback)
exec xclip -selection clipboard >/dev/null 2>&1
