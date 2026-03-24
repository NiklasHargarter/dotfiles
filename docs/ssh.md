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

## services like github

    auth-ui github

## server with ssh-copy-id

    auth-server homelab

## 1. Set the service name (change this for each key)

    SERVICE="github"

## 2. Run the generator

    ssh-keygen -t ed25519 -C "niklas@$(hostname)-to-$SERVICE" -f ~/.ssh/id_ed25519_$SERVICE -N ""

## 3. Copy key to host

    ssh-copy-id -i ~/.ssh/id_ed25519_${SERVICE}.pub $SERVICE
