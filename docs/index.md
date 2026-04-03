---
title: Home
layout: home
---

## System Packages required

### For mac with brew

```bash
brew install stow zsh eza ripgrep curl git fzf fd tree-sitter-cli lazygit wget node luarocks ast-grep gh zellij
```

### For Ubuntu

```bash
sudo apt install stow zsh eza ripgrep curl git fzf fd-find tree-sitter-cli wget nodejs npm luarocks gh lazygit
```


### Zellij
```bash
# 1. Download the latest version
wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
# 2. Extract it
tar -xvf zellij-x86_64-unknown-linux-musl.tar.gz
# 3. Move it to your path (no sudo needed if you use ~/.local/bin)
mkdir -p ~/.local/bin
mv zellij ~/.local/bin/
```
