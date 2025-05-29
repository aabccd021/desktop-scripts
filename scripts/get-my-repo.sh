gh auth status >/dev/null 2>&1
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "You are not authenticated with GitHub. Please run 'gh auth login'."
  exit "$exit_code"
fi

selected=$(gh repo list --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | fzf)
ghq get "https://$(gh auth token)@github.com/$selected"
