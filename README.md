# Dotfiles Configuration

This repository uses GNU Stow to manage system configurations. It follows the XDG Base Directory specification, keeping the home directory clean by moving Zsh configurations into ~/.config/zsh.
Prerequisites

The following packages must be installed:

    zsh

    git

    stow

    Nerd Font (e.g., JetBrainsMono or MesloLGS NF)

Installation
1. Repository Setup

Clone the repository to your home directory:
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
2. Theme and Plugin Installation

Install the Powerlevel10k theme and required Zsh plugins:
Powerlevel10k Theme

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
3. Deploying Configs

Remove existing default files to avoid Stow conflicts:
rm ~/.zshrc

Apply the configuration:
cd ~/dotfiles
stow zsh
Configuration Logic
Path Redirection

The system uses ~/.zshenv to redirect the Zsh configuration directory ($ZDOTDIR) to ~/.config/zsh. This allows the home directory to remain uncluttered.
File Mapping

Stow maps the files as follows:

    ~/dotfiles/zsh/.zshenv -> ~/.zshenv

    ~/dotfiles/zsh/.config/zsh/.zshrc -> ~/.config/zsh/.zshrc

    ~/dotfiles/zsh/.config/zsh/.p10k.zsh -> ~/.config/zsh/.p10k.zsh

Usage and Maintenance

    Sync Changes: Run stow -R zsh inside the ~/dotfiles directory to refresh links.

    New Machines: Install prerequisites, clone the repo, install theme/plugins, and run the stow command.

    Local Settings: Use ~/.zshrc.local for machine-specific environment variables or secrets. This file is ignored by git.onfigs to be used with stow
