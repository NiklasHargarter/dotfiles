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

For UI services (e.g. GitHub — copies public key to clipboard):

    ./scripts/setup-ssh-keys.sh ui github

For servers (generates key + ssh-copy-id):

    ./scripts/setup-ssh-keys.sh server slifer
    ./scripts/setup-ssh-keys.sh server mimir

## Switch dotfiles remote from HTTPS to SSH

After SSH keys are set up, run the bootstrap script or switch manually:

    ./scripts/setup-dotfiles-ssh.sh

## cleanup

```bash
# Unstow config
cd ~/dotfiles && stow -D ssh

# Remove the Include line from ~/.ssh/config
sed -i '/Include ~\/.config\/ssh\/config/d' ~/.ssh/config

# Optionally remove generated keys
rm -f ~/.ssh/id_ed25519_github{,.pub}
rm -f ~/.ssh/id_ed25519_slifer{,.pub}
rm -f ~/.ssh/id_ed25519_mimir{,.pub}

# Remove stow target directory if empty
rmdir ~/.config/ssh 2>/dev/null
```

Keys on remote servers (deployed via `ssh-copy-id`) must be removed manually from each host's `~/.ssh/authorized_keys`.
