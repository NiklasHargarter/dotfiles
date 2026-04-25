---
layout: default
title: VPN Setup
---

## Overview

The Cisco Secure Client VPN aliases are loaded automatically when the Cisco binary is detected at `/opt/cisco/secureclient/bin/vpn`. On machines without it, the aliases are skipped.

## Stow

```bash
stow ciscosecureclient
```

This stows `~/.vpn-creds.template` into your home directory.

## Create credentials file

Copy the template and fill in your actual values:

```bash
cp ~/.vpn-creds.template ~/.vpn-creds
chmod 600 ~/.vpn-creds
```

Edit `~/.vpn-creds` with your real gateway, username, and password:

```
connect your-vpn-gateway.com
0
YOUR_USERNAME
YOUR_PASSWORD
y
```

| Line | Purpose |
|---|---|
| `connect ...` | VPN gateway hostname |
| `0` | Connection profile index (first profile) |
| `YOUR_USERNAME` | Your VPN username |
| `YOUR_PASSWORD` | Your VPN password |
| `y` | Accept the banner |

**The real `~/.vpn-creds` file is gitignored and must never be committed.**

## Usage

| Alias | Action |
|---|---|
| `vpnup` | Connect using saved credentials |
| `vpndown` | Disconnect |
| `vpnstat` | Show connection statistics |

## cleanup

```bash
# Unstow template
cd ~/dotfiles && stow -D ciscosecureclient

# Remove credentials file
rm -f ~/.vpn-creds ~/.vpn-creds.template
```

The Cisco Secure Client application itself is managed separately (installed by IT / system admin).
