#!/usr/bin/env bash
# run-gh-workflow: Run GitHub Actions workflow steps locally
#
# Parses GitHub Actions workflow files, allows selection of workflow
# and job via fzf, extracts the run steps, and executes them locally.
# Useful for testing workflow commands without pushing to GitHub.

workflow_file_input="${1:-}"

# Change to repository root
repo_root=$(git rev-parse --show-toplevel || true)
trap 'cd $(pwd)' EXIT
cd "$repo_root" || exit 1

# Find workflow files
workflow_files=$(find .github/workflows -type f)
if [ -z "$workflow_files" ]; then
  echo "No workflow files found in .github/workflows"
  exit 1
fi

# Select workflow file
if [ "$(echo "$workflow_files" | wc -l)" -eq 1 ]; then
  selected_workflow_file=$(printf "%s" "$workflow_files")
elif [ -n "$workflow_file_input" ]; then
  selected_workflow_file="./.github/workflows/$workflow_file_input"
else
  selected_workflow_file=$(echo "$workflow_files" | fzf)
fi

# Get jobs from workflow
jobs=$(yq --raw-output '.jobs | keys | .[]' "$selected_workflow_file")
if [ -z "$jobs" ]; then
  echo "No jobs found in $selected_workflow_file"
  exit 1
fi

# Select job
if [ "$(echo "$jobs" | wc -l)" -eq 1 ]; then
  selected_job=$(printf "%s" "$jobs")
else
  selected_job=$(echo "$jobs" | fzf)
fi

# Extract and execute run steps
steps=$(yq --raw-output ".jobs.$selected_job.steps[] | select(.run) | .run" "$selected_workflow_file")
sh -eu -c "$steps"
