git ls-remote --heads |
  sed 's/.*refs\/heads\/\([a-zA-Z0-9./_-]*\)/\1/' |
  fzf --no-multi |
  xargs -I {} git fetch origin {}:{}
