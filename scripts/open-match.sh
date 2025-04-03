config_file=""
urls=""

while [ $# -gt 0 ]; do
  case "$1" in
  --config)
    config_file="$2"
    shift 2
    ;;
  *)
    urls="$urls $1"
    shift
    ;;
  esac
done

config=$(cat "$config_file")

for url in $urls; do
  rules_count=$(echo "$config" | jq 'length')
  i=0
  while [ $i -lt "$rules_count" ]; do
    rule=$(echo "$config" | jq -c ".[$i]")
    match_type=$(echo "$rule" | jq -r '.[0]')

    if [ "$match_type" = "prefix" ]; then
      url_pattern=$(echo "$rule" | jq -r '.[1]')
      handler=$(echo "$rule" | jq -r '.[2]')

      case "$url" in
      "$url_pattern"*)
        $handler "$url" &
        break
        ;;
      esac
    elif [ "$match_type" = "all" ]; then
      handler=$(echo "$rule" | jq -r '.[1]')
      $handler "$url" &
      break
    fi

    i=$((i + 1))
  done
done

wait
exit 0
