#!/bin/sh
# Generate and create a git commit using Claude AI

prompt="Create a commit. Don't hesitate to create multiple commits if appropriate - each commit should be minimal and meaningful"
if [ $# -gt 0 ]; then
  prompt="$prompt. $*"
fi

claude --print "$prompt" \
  --allowedTools "Bash(git:*)"
