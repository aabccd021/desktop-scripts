gh repo list --limit 100 --json name --jq '.[].name' |
  fzf |
  xargs ghq get --shallow
