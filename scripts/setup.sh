#!/usr/bin/env bash
# Full non-interactive dotfiles setup.
# Safe to re-run — every step is idempotent.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"

step()  { echo ""; echo "==> $*"; }
info()  { echo "    $*"; }
skip()  { echo "    [skip] $*"; }

clone_if_missing() {
    local repo="$1" dest="$2"
    if [[ ! -d "$dest" ]]; then
        git clone --depth=1 "$repo" "$dest"
    else
        skip "already present: $(basename "$dest")"
    fi
}

# ── 1. System packages ─────────────────────────────────────────────────────────
step "Installing system packages"
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "ERROR: Homebrew not found. Install it first: https://brew.sh" >&2
        exit 1
    fi
    brew install stow zsh eza ripgrep curl git fzf fd tree-sitter-cli wget node luarocks ast-grep gh zellij
elif [[ "$OS" == "Linux" ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y stow zsh eza ripgrep curl git fzf fd-find tree-sitter-cli wget nodejs npm luarocks gh python3-venv

    if ! command -v zellij >/dev/null; then
        mkdir -p ~/.local/bin
        curl -fsSLo /tmp/zellij.tar.gz https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
        tar -xf /tmp/zellij.tar.gz -C /tmp zellij
        mv /tmp/zellij ~/.local/bin/
        rm /tmp/zellij.tar.gz
    else
        skip "zellij already installed"
    fi
fi

# ── 2. Pre-create directories ──────────────────────────────────────────────────
step "Pre-creating config directories"
mkdir -p ~/.config/zsh ~/.config/ssh ~/.config/nvim ~/.config/alacritty \
         ~/.config/ccstatusline ~/.claude ~/.ssh
chmod 700 ~/.ssh

# ── 3. Stow packages ───────────────────────────────────────────────────────────
step "Stowing packages"
cd "$DOTFILES"
stow zsh git ssh nvim alacritty ciscosecureclient claude
[[ "$OS" == "Darwin" ]] && stow aerospace || skip "aerospace (macOS only)"
info "Done."

# ── 4. Default shell ───────────────────────────────────────────────────────────
step "Setting zsh as default shell"
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    grep -qF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
    info "Default shell → $ZSH_PATH"
else
    skip "already using zsh"
fi

# ── 5. SSH include line ────────────────────────────────────────────────────────
step "Configuring SSH"
SSH_CONF=~/.ssh/config
touch "$SSH_CONF" && chmod 600 "$SSH_CONF"
if ! grep -qF "Include ~/.config/ssh/config" "$SSH_CONF"; then
    # sed '1s/^/...' is silent on empty files on macOS; use printf + cat instead
    printf 'Include ~/.config/ssh/config\n\n' | cat - "$SSH_CONF" > "${SSH_CONF}.tmp"
    mv "${SSH_CONF}.tmp" "$SSH_CONF" && chmod 600 "$SSH_CONF"
    info "Include line added to ~/.ssh/config"
else
    skip "Include line already present"
fi

# ── 6. Oh My Zsh ──────────────────────────────────────────────────────────────
step "Installing Oh My Zsh"
if [[ ! -d ~/.oh-my-zsh ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    skip "already installed"
fi

# OMZ installer backs up the stowed .zshrc symlink and drops a real file in its
# place — restore all zsh symlinks so the dotfiles version wins
rm -f "${HOME}/.config/zsh/.zshrc" "${HOME}/.config/zsh/.zshrc.pre-oh-my-zsh"
cd "$DOTFILES" && stow --restow zsh
info "Restored .zshrc symlink"

# ── 7. Powerlevel10k + plugins ────────────────────────────────────────────────
step "Installing Powerlevel10k and plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing https://github.com/romkatv/powerlevel10k.git             "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-completions.git        "$ZSH_CUSTOM/plugins/zsh-completions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/Aloxaf/fzf-tab.git                   "$ZSH_CUSTOM/plugins/fzf-tab"

# Pre-install gitstatus binary so p10k doesn't prompt/download on first shell open
step "Pre-installing gitstatus binary"
"$ZSH_CUSTOM/themes/powerlevel10k/gitstatus/install" -f

# ── 8. Claude Code ────────────────────────────────────────────────────────────
step "Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

# ── 9. Switch dotfiles remote to SSH ──────────────────────────────────────────
step "Switching dotfiles remote to SSH"
SSH_REMOTE="git@github.com:niklashargarter/dotfiles.git"
current_remote=$(git -C "$DOTFILES" remote get-url origin 2>/dev/null || true)
if [[ "$current_remote" == "$SSH_REMOTE" ]]; then
    skip "remote already set to SSH"
else
    git -C "$DOTFILES" remote set-url origin "$SSH_REMOTE"
    info "Remote → $SSH_REMOTE"
fi

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "=============================="
echo " Setup complete"
echo "=============================="
echo ""
echo "Next steps:"
echo "  1. Reload shell       exec zsh"
echo "  2. SSH keys           ./scripts/setup-ssh-keys.sh"
echo "  3. VPN credentials    cp ~/.vpn-creds.template ~/.vpn-creds && chmod 600 ~/.vpn-creds"
echo "                        (then edit ~/.vpn-creds with your real values)"
