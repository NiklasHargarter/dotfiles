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

## make scripts executable

```bash
chmod +x ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-wrapper.sh
```

## configure repos directory

Repos are resolved relative to `~/`. If your repositories live in a subdirectory instead (e.g. `~/repos/`), update line 12 of `~/.claude/statusline-command.sh`:

```bash
repo_name=$(echo "$cwd" | sed "s|^$HOME/repos/||")
```

## restart Claude Code

Restart Claude Code to see the status line in action.
