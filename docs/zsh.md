---
layout: default
title: Zsh Setup
---

## download MesloLGS NF

[powerlevel10k github fonts](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts)

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
