---
layout: default
title: SSH
---

# Stow and ssh include
## 1. Stow the repo config
    cd ~/dotfiles && stow ssh

## 2. Ensure the local .ssh folder exists and has right permissions
    mkdir -p ~/.ssh && chmod 700 ~/.ssh

## 3. Add the Include line to the main SSH config
    echo "Include ~/.config/ssh/config" >> ~/.ssh/config
    chmod 600 ~/.ssh/config

# Create keys with helper functions
## services like github
    auth-ui github

## server with ssh-copy-id
    auth-server homelab

# Create keys for each host
## 1. Set the service name (change this for each key)
    SERVICE="github"

## 2. Run the generator
    ssh-keygen -t ed25519 -C "niklas@$(hostname)-to-$SERVICE" -f ~/.ssh/id_ed25519_$SERVICE -N ""

## 3. Copy key to host
    ssh-copy-id -i ~/.ssh/id_ed25519_${SERVICE}.pub $SERVICE

