#!/usr/bin/env bash
# Full dotfiles teardown — removes all stowed config and installed tooling.
# SSH keys are NOT removed (they live on remote servers too).
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"

step() { echo ""; echo "==> $*"; }
info() { echo "    $*"; }
skip() { echo "    [skip] $*"; }

# ── 1. Unstow packages ────────────────────────────────────────────────────────
step "Unstowing packages"
cd "$DOTFILES"
for pkg in zsh git ssh nvim alacritty ciscosecureclient claude; do
    stow -D "$pkg" 2>/dev/null && info "unstowed $pkg" || skip "$pkg not stowed"
done
[[ "$OS" == "Darwin" ]] && { stow -D aerospace 2>/dev/null && info "unstowed aerospace" || skip "aerospace not stowed"; } || skip "aerospace (macOS only)"

# stow -D only removes symlinks it created; OMZ replaces the .zshrc symlink with a
# real file and leaves a .pre-oh-my-zsh backup — remove both so setup can stow cleanly
rm -f ~/.config/zsh/.zshrc ~/.config/zsh/.zshrc.pre-oh-my-zsh \
      && info "removed OMZ .zshrc artifacts" || true

# Remove now-empty stow target directories
rmdir ~/.config/zsh          2>/dev/null && info "removed ~/.config/zsh"          || true
rmdir ~/.config/ssh          2>/dev/null && info "removed ~/.config/ssh"          || true
rmdir ~/.config/nvim         2>/dev/null && info "removed ~/.config/nvim"         || true
rmdir ~/.config/alacritty    2>/dev/null && info "removed ~/.config/alacritty"    || true

# Remove the SSH include line
SSH_CONF=~/.ssh/config
if [[ -f "$SSH_CONF" ]] && grep -qF "Include ~/.config/ssh/config" "$SSH_CONF"; then
    sed -i.bak '/Include ~\/.config\/ssh\/config/d' "$SSH_CONF"
    rm -f "${SSH_CONF}.bak"
    info "SSH include line removed from ~/.ssh/config"
fi

# ── 2. Oh My Zsh + plugins + theme ───────────────────────────────────────────
step "Removing Oh My Zsh"
if [[ -d ~/.oh-my-zsh ]]; then
    rm -rf ~/.oh-my-zsh
    info "removed ~/.oh-my-zsh"
else
    skip "not installed"
fi

# ── 3. Zsh cache ──────────────────────────────────────────────────────────────
step "Removing zsh cache"
rm -rf ~/.zcompdump* ~/.config/zsh/.zcompdump*
info "done"

# ── 4. Neovim data ───────────────────────────────────────────────────────────
step "Removing Neovim data"
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
info "done"

# ── 5. Claude Code ───────────────────────────────────────────────────────────
step "Removing Claude Code"
rm -rf ~/.config/ccstatusline ~/.config/claude
info "done (user data in ~/.claude preserved)"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=============================="
echo " Teardown complete"
echo "=============================="
echo ""
echo "Not removed (manual cleanup if needed):"
echo "  - SSH keys in ~/.ssh/"
echo "  - System packages installed via brew/apt"
