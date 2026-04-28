#!/bin/bash

input=$(cat)

git_info=$(echo "$input" | bash ~/.claude/statusline-command.sh)
context_pct=$(echo "$input" | npx -y ccstatusline@latest)

printf '%s | %s' "$git_info" "$context_pct"
