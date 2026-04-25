---
layout: default
title: Git Setup
---

## stow

```bash
stow git
```

Stow links `~/.gitconfig` directly into the home directory — no directory pre-creation needed.

## cleanup

```bash
cd ~/dotfiles && stow -D git
```

This removes the `~/.gitconfig` symlink. Git will fall back to its defaults.
