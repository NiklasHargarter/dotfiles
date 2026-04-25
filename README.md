# Dotfiles Configuration

This repository manages my system configurations using **GNU Stow**. It adheres to the **XDG Base Directory specification**, keeping the `$HOME` directory clean by moving configurations into `~/.config`.

For detailed setup instructions, visit [the official documentation](https://niklashargarter.github.io/dotfiles/).

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/niklashargarter/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Pre-create config directories (prevents stow from symlinking entire dirs)
mkdir -p ~/.config/zsh ~/.config/nvim ~/.config/alacritty ~/.config/ssh
mkdir -p ~/.claude ~/.config/ccstatusline

# 3. Stow the modules you need (pick and choose)
stow zsh git ssh nvim          # essentials (any machine)
stow alacritty aerospace       # desktop / macOS only
stow claude                    # Claude Code config
stow ciscosecureclient         # VPN credentials template (see docs/vpn.md)
```

## Switch from HTTPS to SSH

After cloning over HTTPS, run the bootstrap script to generate a GitHub SSH key and switch the remote:

```bash
./scripts/setup-dotfiles-ssh.sh
```

## SSH Key Setup for Servers / Services

`~/.config/ssh/config` is the source of truth — every Host block tagged with a
`# deploy: server|manual` marker is picked up by the key setup script. Run with
no args to set up every annotated host, or pass a specific Host alias:

```bash
./scripts/setup-ssh-keys.sh              # set up every annotated Host
./scripts/setup-ssh-keys.sh slifer       # only this one
```

`server` mode runs `ssh-copy-id` for you; `manual` mode copies the pubkey to
your clipboard so you can paste it into a web UI (GitHub, GitLab self-hosted,
Forgejo, …). See [docs/ssh.md](docs/ssh.md) for the full walkthrough including
how to add a new machine or service.

## The Stack

- **Window Manager:** [Aerospace](https://github.com/nikitabobko/AeroSpace) (macOS tiling)
- **Terminal:** [Alacritty](https://alacritty.org/)
- **Editor:** [Neovim](https://neovim.io/) (via [LazyVim](https://www.lazyvim.org/))
- **Shell:** [Zsh](https://www.zsh.org/) with [Oh My Zsh](https://ohmyz.sh/) & [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **SSH:** Modular config
- **AI CLI:** [Claude Code](https://claude.ai/code) (Status line with git info & context %)

## Modularity

Zsh loads topic files from `zsh/.config/zsh/conf.d/`. Each file guards its own dependencies so it's safe to stow everywhere:

```zsh
# conf.d/zellij.zsh — only loads if zellij is installed
command -v zellij >/dev/null || return
alias z='zellij'
```

To add aliases for a new tool, create a new file in `conf.d/` with a guard — no other files need editing.

## Requirements

- **GNU Stow** (The symlink manager)
- **Zsh** (Default shell)
- **Git** (Version control)
- **curl/wget** (For installation scripts)

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y stow zsh git curl
```
