---
layout: default
title: Zsh Setup
---

## download MesloLGS NF

[powerlevel10k github fonts](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts)

## how it works

`.zshenv` is stowed to `~/.zshenv` (the only file in `$HOME`) because zsh reads it before `ZDOTDIR` is set. It sets `ZDOTDIR=~/.config/zsh`, which redirects all other zsh config to XDG.

## set zsh as default shell

```bash
chsh -s $(which zsh)
```

## set zsh as default for root user

```bash
sudo chsh -s $(which zsh) root
```

## pre-create config directory

Required before stow so that stow links individual files instead of symlinking the entire directory into the repo.

```bash
mkdir -p ~/.config/zsh
```

## stow

```bash
stow zsh
```

## restart shell

`.zshenv` was just stowed and sets `ZDOTDIR`. A new shell session is required for it to take effect.

```bash
exec zsh
```

## check for custom zsh config location

Confirm `ZDOTDIR` is now set correctly (should be `~/.config/zsh`).

```bash
echo $ZDOTDIR
```

## install ohmyzsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

When prompted about an existing `.zshrc`, select **keep** to preserve the stowed symlink.

## Powerlevel 10k

`ZSH` is set to `~/.oh-my-zsh` in `.zshrc` and no custom `ZSH_CUSTOM` path is used — plugins and themes always go into `~/.oh-my-zsh/custom`.

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
```

## Plugins

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

## modular aliases (conf.d/)

Tool-specific aliases live in `zsh/.config/zsh/conf.d/`. Each file guards itself so it only loads when the tool is available:

```zsh
# conf.d/zellij.zsh
command -v zellij >/dev/null || return
alias z='zellij'
```

To add aliases for a new tool, create a new `.zsh` file in `conf.d/` — no other files need editing.

Current topic files:

| File | Tool | Guard |
|---|---|---|
| `zellij.zsh` | Zellij | `command -v zellij` |
| `vpn.zsh` | Cisco Secure Client | `/opt/cisco/secureclient/bin/vpn` exists |

## cleanup

Remove all zsh config and return to a fresh state.

```bash
# Unstow config files
cd ~/dotfiles && stow -D zsh

# Remove Oh My Zsh (includes plugins and themes)
rm -rf ~/.oh-my-zsh

# Remove zsh cache and history
rm -rf ~/.config/zsh/.zsh_history ~/.config/zsh/.zcompdump*
rm -rf ~/.zcompdump*

# Reset default shell to bash
chsh -s $(which bash)
```

After re-setup, follow all steps from [set zsh as default shell](#set-zsh-as-default-shell) onwards.

## usage guide

### plugins

| Plugin | What it gives you |
|---|---|
| `git` | Aliases: `gst`, `gco`, `gcmsg`, `gl`, `gp`, etc. |
| `fzf` | Fuzzy finder widgets and keybindings |
| `eza` | Nicer `ls`, `ll`, `la`, `lD` aliases |
| `zsh-autosuggestions` | Grey inline suggestions from history |
| `zsh-completions` | Extra completion definitions |
| `fzf-tab` | fzf UI for Tab completion menus |
| `zsh-syntax-highlighting` | Colors commands as you type |

### key bindings

| Key | Action |
|---|---|
| `Ctrl + A` / `Ctrl + E` | Move to start / end of line |
| `Alt + B` / `Alt + F` | Move back / forward one word |
| `Ctrl + W` | Delete previous word |
| `Ctrl + U` / `Ctrl + K` | Delete to line start / end |
| `Ctrl + Y` | Paste last killed text |
| `Ctrl + R` | Fuzzy search command history (fzf) |
| `Ctrl + T` | Fuzzy insert file/path |
| `Alt + C` | Fuzzy jump to directory |
| `Right Arrow` | Accept autosuggestion |
| `Tab` | Trigger fzf-tab completion |
