#!/bin/bash
# Statusline: "<repo> | <branch> | S:0 U:2 A:0 | ctx 18% · 36k/200k"
# git info from statusline-command.sh, context usage from statusline-context.py
# (pure stdlib, no network — replaces the old npx ccstatusline call).

input=$(cat)

git_info=$(printf '%s' "$input" | bash ~/.claude/statusline-command.sh)
ctx=$(printf '%s' "$input" | python3 ~/.claude/statusline-context.py 2>/dev/null)

if [ -n "$ctx" ]; then
  printf '%s | %s' "$git_info" "$ctx"
else
  printf '%s' "$git_info"
fi
