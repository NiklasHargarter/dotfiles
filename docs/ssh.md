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

The SSH config at `~/.config/ssh/config` is the **single source of truth** for
every machine and service: hostname, user, key path, and how the key is
deployed. `scripts/setup-ssh-keys.sh` reads that config and generates / deploys
keys accordingly — there is no separate inventory file.

### How a Host block becomes an actionable entry

Each managed `Host` block has three things:

1. A `# deploy: server` or `# deploy: manual` comment on the line directly
   above it. Without this marker the script ignores the block.
2. `HostName` and `User` so SSH knows where to connect.
3. `IdentityFile` so the script knows where to write the generated key.

```sshconfig
# deploy: server
Host slifer
    HostName 193.175.188.174
    User niklas
    IdentityFile ~/.ssh/id_ed25519_slifer

# deploy: manual
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
```

### Deploy modes

| Mode     | What the script does                                                                              | When to use                                                                                                                  |
| -------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `server` | Generates the key at `IdentityFile`, then runs `ssh-copy-id <Host>` to install the pubkey for you | You have password (or other) SSH access to the host                                                                          |
| `manual` | Generates the key at `IdentityFile`, then copies the pubkey to your clipboard                     | You have to paste the pubkey into a web UI yourself (GitHub, GitLab hosted *and* self-hosted, Forgejo, Gitea, Bitbucket, …) |

Common paste locations for `manual` services:

| Service              | Where to paste                                        |
| -------------------- | ----------------------------------------------------- |
| GitHub               | <https://github.com/settings/ssh/new>                 |
| GitLab (hosted)      | <https://gitlab.com/-/user_settings/ssh_keys>         |
| GitLab (self-hosted) | `https://<your-gitlab-host>/-/user_settings/ssh_keys` |
| Forgejo / Gitea      | `https://<host>/user/settings/keys`                   |

### Running the script

```bash
# Process every annotated Host (skip ones whose key already exists)
./scripts/setup-ssh-keys.sh

# Process only one Host alias
./scripts/setup-ssh-keys.sh slifer
./scripts/setup-ssh-keys.sh github.com

# Point at a different config file (e.g. for testing)
SSH_CONFIG=./ssh/.config/ssh/config ./scripts/setup-ssh-keys.sh
```

The script is idempotent: if the key already exists at `IdentityFile`, it skips
generation but will still run `ssh-copy-id` (server mode) or re-copy the pubkey
to the clipboard (manual mode), so it's safe to re-run.

### Adding a new machine or service

1. Add a Host block to `ssh/.config/ssh/config` with a `# deploy:` marker and
   an `IdentityFile` path.
2. Restow if needed (`stow ssh` already linked the file, so edits to the
   stowed file are live).
3. Run `./scripts/setup-ssh-keys.sh <host>` to generate the key and deploy it.

Example — adding a self-hosted GitLab:

```sshconfig
# deploy: manual
Host gitlab.example.com
    HostName gitlab.example.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab-work
```

```bash
./scripts/setup-ssh-keys.sh gitlab.example.com
# → key written to ~/.ssh/id_ed25519_gitlab-work
# → pubkey on clipboard, paste into https://gitlab.example.com/-/user_settings/ssh_keys
```

## Switch dotfiles remote from HTTPS to SSH

After SSH keys are set up, run the bootstrap script or switch manually:

    ./scripts/setup-dotfiles-ssh.sh

## cleanup

```bash
# Unstow config
cd ~/dotfiles && stow -D ssh

# Remove the Include line from ~/.ssh/config
sed -i '/Include ~\/.config\/ssh\/config/d' ~/.ssh/config

# Optionally remove generated keys (adjust suffixes to match what you generated)
rm -f ~/.ssh/id_ed25519_github{,.pub}
rm -f ~/.ssh/id_ed25519_slifer{,.pub}
rm -f ~/.ssh/id_ed25519_mimir{,.pub}

# Remove stow target directory if empty
rmdir ~/.config/ssh 2>/dev/null
```

Keys on remote servers (deployed via `ssh-copy-id`) must be removed manually from each host's `~/.ssh/authorized_keys`.
