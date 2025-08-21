workflow_file_input="${1:-}"

repo_root=$(git rev-parse --show-toplevel || true)
trap 'cd $(pwd)' EXIT
cd "$repo_root" || exit 1

workflow_files=$(find .github/workflows -type f)
if [ -z "$workflow_files" ]; then
  echo "No workflow files found in .github/workflows"
  exit 1
fi

if [ "$(echo "$workflow_files" | wc -l)" -eq 1 ]; then
  selected_workflow_file=$(printf "%s" "$workflow_files")
elif [ -n "$workflow_file_input" ]; then
  selected_workflow_file="./.github/workflows/$workflow_file_input"
else
  selected_workflow_file=$(echo "$workflow_files" | fzf)
fi

jobs=$(yq --raw-output '.jobs | keys | .[]' "$selected_workflow_file")
if [ -z "$jobs" ]; then
  echo "No jobs found in $selected_workflow_file"
  exit 1
fi

if [ "$(echo "$jobs" | wc -l)" -eq 1 ]; then
  selected_job=$(printf "%s" "$jobs")
else
  selected_job=$(echo "$jobs" | fzf)
fi

steps=$(yq --raw-output ".jobs.$selected_job.steps[] | select(.run) | .run" "$selected_workflow_file")
sh -eu -c "$steps"
