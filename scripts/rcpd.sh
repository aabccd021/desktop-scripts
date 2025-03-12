rsync \
  --delete \
  --archive \
  --verbose \
  --progress \
  --partial \
  --filter=':- .gitignore' \
  --exclude=.git \
  "$@"
