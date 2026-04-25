---
title: Home
layout: home
---

## Setup Order

1. [Install system packages](#system-packages-required) (below)
2. [Zsh](zsh.md) — shell, oh-my-zsh, plugins, theme
3. [Git](git.md) — global config
4. [SSH](ssh.md) — modular key management
5. [Neovim](nvim.md) — editor with LazyVim
6. [Claude Code](claude.md) — AI CLI with status line *(optional)*
7. [Alacritty](alacritty.md) — terminal emulator *(desktop only)*
8. [Aerospace](aerospace.md) — tiling window manager *(macOS only)*
9. [VPN](vpn.md) — Cisco Secure Client *(optional, desktop only)*

## System Packages required

### For mac with brew

```bash
brew install stow zsh eza ripgrep curl git fzf fd tree-sitter-cli lazygit wget node luarocks ast-grep gh zellij
```

### For Ubuntu

```bash
sudo apt install stow zsh eza ripgrep curl git fzf fd-find tree-sitter-cli wget nodejs npm luarocks gh python3-venv
```

lazygit is not in the default Ubuntu repos — install via [the official instructions](https://github.com/jesseduffield/lazygit#ubuntu).

### Zellij (manual install for Linux)

```bash
# 1. Download the latest version
wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
# 2. Extract it
tar -xvf zellij-x86_64-unknown-linux-musl.tar.gz
# 3. Move it to your path (no sudo needed if you use ~/.local/bin)
mkdir -p ~/.local/bin
mv zellij ~/.local/bin/
```

## Post-clone setup

### Switch dotfiles remote from HTTPS to SSH

```bash
./scripts/setup-dotfiles-ssh.sh
```

### Generate SSH keys for servers / services

```bash
# For servers (uses ssh-copy-id)
./scripts/setup-ssh-keys.sh server <host>

# For UI services like GitHub (copies public key to clipboard)
./scripts/setup-ssh-keys.sh ui github
```

### VPN credentials (optional, desktop only)

See [VPN Setup](vpn.md) for Cisco Secure Client configuration.
