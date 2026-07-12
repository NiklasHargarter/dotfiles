#!/usr/bin/env bash
# Unlink dotfiles from this machine — the SAFE, universal reset.
# Only removes symlinks this repo created; touches no packages or app data.
# For a deeper wipe (tooling, caches, per-machine cruft) see the README.
set -euo pipefail

OS="$(uname -s)"
step() { echo ""; echo "==> $*"; }
info() { echo "    $*"; }
skip() { echo "    [skip] $*"; }

# remove only if it's a symlink we created
unlink_dot() {
    local dst="$1"
    if [[ -L "$dst" ]]; then rm "$dst" && info "unlinked ${dst/#$HOME/\~}"; else skip "${dst/#$HOME/\~} not a symlink"; fi
}

step "Unlinking dotfiles"
unlink_dot ~/.zshenv
unlink_dot ~/.config/zsh/.zshrc
unlink_dot ~/.config/zsh/.p10k.zsh
unlink_dot ~/.config/zsh/conf.d/aliases.zsh
unlink_dot ~/.config/zsh/conf.d/vpn.zsh
unlink_dot ~/.config/zsh/conf.d/zellij.zsh
unlink_dot ~/.gitconfig
unlink_dot ~/.config/ssh/config
unlink_dot ~/.claude/settings.json
unlink_dot ~/.claude/statusline-command.sh
unlink_dot ~/.claude/statusline-context.py
unlink_dot ~/.claude/statusline-wrapper.sh
unlink_dot ~/.claude/scripts/link-vendor-skills.sh
unlink_dot ~/.config/ghostty/config
unlink_dot ~/.config/alacritty/alacritty.toml
[[ "$OS" == "Darwin" ]] && unlink_dot ~/.aerospace.toml

# OMZ may have left a real .zshrc + backup where our symlink was
rm -f ~/.config/zsh/.zshrc ~/.config/zsh/.zshrc.pre-oh-my-zsh 2>/dev/null || true

step "Removing now-empty config dirs"
for d in ~/.config/zsh/conf.d ~/.config/zsh ~/.config/ssh ~/.config/ghostty ~/.config/alacritty; do
    rmdir "$d" 2>/dev/null && info "removed ${d/#$HOME/\~}" || true
done

step "Removing SSH include line"
SSH_CONF=~/.ssh/config
if [[ -f "$SSH_CONF" ]] && grep -qF "Include ~/.config/ssh/config" "$SSH_CONF"; then
    sed -i.bak '/Include ~\/.config\/ssh\/config/d' "$SSH_CONF"
    rm -f "${SSH_CONF}.bak"
    info "removed from ~/.ssh/config"
fi

echo ""
echo "Dotfiles unlinked. Config is gone; installed tooling (zsh, omz, nvim,"
echo "claude, brew/apt packages) is untouched — see the Teardown section of"
echo "the README for a full per-machine wipe, including a prompt to hand Claude."
