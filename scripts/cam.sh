#!/usr/bin/env bash
# cam: Interactive webcam viewer with low latency
#
# Lists available video devices, allows selection via fzf,
# and opens the selected camera with ffplay using low-latency settings.

# Let user select a video device
device=$(find /dev -name 'video*' | fzf)

# Open camera feed with minimal latency settings
ffplay \
  -f v4l2 \
  -max_delay 0 \
  -max_probe_packets 1 \
  -analyzeduration 0 \
  -flags +low_delay \
  -fflags +nobuffer \
  -nostats \
  "$device"
