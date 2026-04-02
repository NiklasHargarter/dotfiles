#!/bin/bash

# Read JSON input once
input=$(cat)

# Get git info from existing script
git_info=$(echo "$input" | bash ~/.claude/statusline-command.sh)

# Get context percentage from ccstatusline
context_pct=$(echo "$input" | npx ccstatusline)

# Write context snapshot for agent self-monitoring
# Extract numeric percentage from ccstatusline output (e.g. "67.0%" -> "67.0")
pct=$(echo "$context_pct" | grep -oE '[0-9]+(\.[0-9]+)?%' | tr -d '%' | head -1)
session=$(echo "$input" | sed -n 's/.*"session_id":"\([^"]*\)".*/\1/p' | head -1)
if [ -n "$pct" ]; then
  printf '{"percentage":%s,"timestamp":"%s","session_id":"%s"}\n' \
    "$pct" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$session" \
    > ~/.claude/context-percentage.json
fi

# Combine outputs
printf '%s | %s' "$git_info" "$context_pct"
