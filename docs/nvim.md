---
layout: default
title: Neovim Setup
---

## pre-create config directory

Required before stow so that stow links individual files instead of symlinking the entire directory into the repo.

```bash
mkdir -p ~/.config/nvim
```

## stow

```bash
stow nvim
```

## install plugins

Open nvim — lazy.nvim will automatically install all plugins on first launch.

```bash
nvim
```
