---
layout: default
title: Aerospace Setup
---

## stow

```bash
stow aerospace
```

Stow links `~/.aerospace.toml` directly into the home directory — no directory pre-creation needed.

## reload config

```bash
aerospace reload-config
```

## cleanup

```bash
cd ~/dotfiles && stow -D aerospace
```

This removes the `~/.aerospace.toml` symlink. Aerospace will fall back to its defaults on next reload.
