device=$(find /dev -name 'video*' | fzf)

ffplay \
  -f v4l2 \
  -max_delay 0 \
  -max_probe_packets 1 \
  -analyzeduration 0 \
  -flags +low_delay \
  -fflags +nobuffer \
  -nostats \
  "$device"
