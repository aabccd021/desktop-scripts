repo_url="$1"

repo_path=$(
  echo "$repo_url" |
    sed 's|https://github.com/||' |
    cut -d '/' -f 1,2
)

size=$(
  gh api "/repos/$repo_path" \
    --jq '.size' |
    numfmt --to=iec --from-unit=1024
)

echo "Repository size: $size"
printf "Proceed to clone? [y/n]: "
read -r answer
if [ "$answer" = "y" ]; then
  ghq get --shallow "$repo_url"
else
  echo "Aborted"
fi
