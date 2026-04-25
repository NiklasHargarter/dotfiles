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

## cleanup

```bash
# Unstow config
cd ~/dotfiles && stow -D nvim

# Remove plugin data, cache, and state
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Remove stow target directory if empty
rmdir ~/.config/nvim 2>/dev/null
```

After re-setup, plugins will re-install automatically on first launch.
