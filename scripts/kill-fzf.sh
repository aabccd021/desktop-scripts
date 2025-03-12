pid=$(
  ps -eo pid,pcpu,pmem,cmd --no-headers |
    fzf --header="Select process to kill" |
    awk '{print $1}'
)

if [ -z "$pid" ]; then
  echo "No process selected"
  exit 0
fi

kill -9 "$pid"
