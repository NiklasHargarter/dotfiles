---
layout: default
title: Alacritty Setup
---

## pre-create config directory

Required before stow so that stow links individual files instead of symlinking the entire directory into the repo.

```bash
mkdir -p ~/.config/alacritty
```

## stow

```bash
stow alacritty
```

## cleanup

```bash
cd ~/dotfiles && stow -D alacritty
rmdir ~/.config/alacritty 2>/dev/null
```
