#!/bin/bash

# Symlinks all skills from the vendor/mattpocock-skills submodule into ~/.claude/skills/
# Run once on setup, and again after `git submodule update --remote vendor/mattpocock-skills`

VENDOR="$HOME/dotfiles/vendor/mattpocock-skills"
TARGET="$HOME/.claude/skills"

mkdir -p "$TARGET"

for skill_dir in "$VENDOR"/*/; do
  skill=$(basename "$skill_dir")
  if [ ! -e "$TARGET/$skill" ]; then
    ln -s "$skill_dir" "$TARGET/$skill"
    echo "linked: $skill"
  else
    echo "skipped (exists): $skill"
  fi
done
