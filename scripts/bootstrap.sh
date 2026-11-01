#!/usr/bin/env bash
# New-machine entry point. Stay at the keyboard: it may ask for your password.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/niklashargarter/dotfiles/main/scripts/bootstrap.sh)
#
# Not `curl | bash`: stdin must stay a TTY for sudo, Homebrew and claude.
# Does what needs you present, then Claude Code takes over (see CLAUDE.md).
set -euo pipefail

export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

# Homebrew's installer pulls in the Xcode CLT, which is what provides git.
if [[ "$(uname -s)" == Darwin ]]; then
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
elif ! command -v git >/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y git
fi

[[ -d ~/dotfiles ]] || git clone https://github.com/niklashargarter/dotfiles.git ~/dotfiles

# Before setup.sh, so a failed setup still ends with an agent to fix it.
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

~/dotfiles/scripts/setup.sh || echo "setup.sh failed; handing over to Claude."

cd ~/dotfiles
exec claude "Set up this machine."
