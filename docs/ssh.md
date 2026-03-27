---
layout: default
title: SSH
---

## 1. Pre-create config directory

Required before stow so that stow links individual files instead of symlinking the entire directory into the repo.

    mkdir -p ~/.config/ssh

## 2. Stow the repo config

    cd ~/dotfiles && stow ssh

## 3. Ensure the local .ssh folder exists and has right permissions

    mkdir -p ~/.ssh && chmod 700 ~/.ssh

## 4. Add the Include line to the main SSH config

    echo "Include ~/.config/ssh/config" >> ~/.ssh/config
    chmod 600 ~/.ssh/config

## Authenticate services

For UI services (e.g. GitHub — opens browser):

    auth-ui github

For servers (uses ssh-copy-id):

    auth-server slifer
    auth-server mimir

## Switch dotfiles remote from HTTPS to SSH

After SSH keys are set up, switch the origin remote so you can push:

    git -C ~/dotfiles remote set-url origin git@github.com:NiklasHargarter/dotfiles.git
