---
layout: default
title: Claude Code Setup
---

## Result

```
matt/course-video-manager | main | S: 0 | U: 1 | A: 0 | 17.3%
```

- **Repo path** relative to `~/repos/`
- **Git status**: branch, staged (S), unstaged (U), added/untracked (A)
- **Context window** usage percentage — keep it under ~60% for best results

## configure npm global prefix

Avoids needing `sudo` for `npm install -g`. One-time setup:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
```

The `~/.npm-global/bin` PATH entry is already included in the stowed `.zshrc`. Restart your shell after stowing zsh (or source it) before running the installs below.

## install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

## install ccstatusline

```bash
npm install -g ccstatusline
```

## pre-create config directory

Required before stow so that stow links individual files instead of symlinking the entire directory into the repo.

```bash
mkdir -p ~/.claude
mkdir -p ~/.config/ccstatusline
```

## stow

```bash
stow claude
```

## configure repos directory

Repos are resolved relative to `~/`. If your repositories live in a subdirectory instead (e.g. `~/repos/`), update line 12 of `~/.claude/statusline-command.sh`:

```bash
repo_name=$(echo "$cwd" | sed "s|^$HOME/repos/||")
```

## restart Claude Code

Restart Claude Code to see the status line in action.
