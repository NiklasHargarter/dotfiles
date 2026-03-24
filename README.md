# Dotfiles Configuration

This repository manages my system configurations using **GNU Stow**. It adheres to the **XDG Base Directory specification**, keeping the `$HOME` directory clean by moving configurations into `~/.config`.

For detailed setup instructions, visit [the official documentation](https://niklashargarter.github.io/dotfiles/).

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/niklashargarter/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Ensure config directory exists
mkdir -p ~/.config

# 3. Stow your desired configurations
stow zsh nvim alacritty aerospace claude
```

## 🛠️ The Stack

- **Window Manager:** [Aerospace](https://github.com/nikiv/aerospace) (macOS tiling)
- **Terminal:** [Alacritty](https://alacritty.org/)
- **Editor:** [Neovim](https://neovim.io/) (via [LazyVim](https://www.lazyvim.org/))
- **Shell:** [Zsh](https://www.zsh.org/) with [Oh My Zsh](https://ohmyz.sh/) & [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Multiplexer:** [SSH](https://www.openssh.com/) (Modular config)
- **AI CLI:** [Claude Code](https://claude.ai/code) (Status line with git info & context %)

## 📋 Requirements

Ensure you have the following installed before stowing:

- **GNU Stow** (The symlink manager)
- **Zsh** (Default shell)
- **Git** (Version control)
- **curl/wget** (For installation scripts)

```bash
# Debian/Ubuntu example
sudo apt update && sudo apt install -y stow zsh git curl
```
