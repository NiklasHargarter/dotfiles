#!/usr/bin/env bash
# Unlink dotfiles from this machine — the SAFE, universal reset.
# Only removes symlinks this repo created; touches no packages or app data.
# For a deeper wipe (tooling, caches, per-machine cruft) see the README.
set -euo pipefail

OS="$(uname -s)"
step() { echo ""; echo "==> $*"; }
info() { echo "    $*"; }
skip() { echo "    [skip] $*"; }

# DRY_RUN=1 ./teardown.sh  → print what would be removed, change nothing.
DRY_RUN="${DRY_RUN:-}"

# Discovery, not a fixed list: any symlink pointing INTO the dotfiles repo is
# ours, whether the current setup.sh still creates it or it's a stale leftover
# from an old rework (dead links included — readlink still reports the target).
# This is why teardown works on machines that drifted from the current repo.
# Scope stays shallow so we never walk into node_modules / ~/.claude/projects.
step "Unlinking dotfiles (all symlinks that point into ~/dotfiles)"
found=0
while IFS= read -r f; do
    target="$(readlink "$f")"
    case "$target" in
        *dotfiles/*) ;;                       # points into the repo → ours
        *) continue ;;
    esac
    found=1
    if [[ -n "$DRY_RUN" ]]; then
        info "[dry-run] would unlink ${f/#$HOME/\~} -> $target"
        continue
    fi
    rm "$f" && info "unlinked ${f/#$HOME/\~}"
done < <(
    find "$HOME" -maxdepth 1 -type l
    find "$HOME/.config" "$HOME/.claude" -maxdepth 3 -type l 2>/dev/null
)
[[ "$found" == 0 ]] && skip "no dotfiles symlinks found on this machine"

# OMZ may have left a real .zshrc + backup where our symlink was
[[ -z "$DRY_RUN" ]] && rm -f ~/.config/zsh/.zshrc ~/.config/zsh/.zshrc.pre-oh-my-zsh 2>/dev/null || true

step "Removing now-empty config dirs"
if [[ -n "$DRY_RUN" ]]; then
    skip "[dry-run] skipping dir prune"
else
    # Prune any dir left empty under ~/.config after unlinking (walks up too).
    find "$HOME/.config" -depth -type d -empty -delete 2>/dev/null || true
fi

step "Removing SSH include line"
SSH_CONF=~/.ssh/config
if [[ -f "$SSH_CONF" ]] && grep -qF "Include ~/.config/ssh/config" "$SSH_CONF"; then
    if [[ -n "$DRY_RUN" ]]; then
        info "[dry-run] would remove Include line from ~/.ssh/config"
    else
        sed -i.bak '/Include ~\/.config\/ssh\/config/d' "$SSH_CONF"
        rm -f "${SSH_CONF}.bak"
        info "removed from ~/.ssh/config"
    fi
fi

echo ""
echo "Dotfiles unlinked. Config is gone; installed tooling (zsh, omz, nvim,"
echo "claude, brew/apt packages) is untouched — see the Teardown section of"
echo "the README for a full per-machine wipe, including a prompt to hand Claude."
