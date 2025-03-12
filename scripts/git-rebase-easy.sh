target_branch="$1"
if [ -z "$target_branch" ]; then
  target_branch=$(
    git branch --all --no-color --sort=-committerdate |
      grep -v HEAD |
      sed 's/.* //' |
      fzf --no-multi
  )
fi

num_slash=$(echo "$target_branch" | grep -c '/')
if [ "$num_slash" -eq 1 ]; then
  echo "Remote branch selected as target. Fetching the remote branch"
  remote=$(echo "$target_branch" | cut -d '/' -f 1)
  branch=$(echo "$target_branch" | cut -d '/' -f 2)
  git fetch "$remote" "$branch"
fi

merge_base=""
while [ -z "$merge_base" ]; do
  merge_base=$(git merge-base HEAD "$target_branch")
  git fetch --deepen=10
done

git rebase --onto "$target_branch" "$merge_base"
