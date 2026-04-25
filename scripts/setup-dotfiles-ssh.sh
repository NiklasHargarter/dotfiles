#!/usr/bin/env bash
# Bootstrap SSH access for this dotfiles repo.
#
# 1. Generates a GitHub SSH key (if missing)
# 2. Copies / prints the public key so you can add it to GitHub
# 3. Switches the dotfiles remote from HTTPS to SSH
set -euo pipefail

KEYFILE="$HOME/.ssh/id_ed25519_github"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SSH_REMOTE="git@github.com:niklashargarter/dotfiles.git"

# --- Step 1: Generate key ---
if [[ ! -f "$KEYFILE" ]]; then
    echo "--- Generating GitHub SSH key ---"
    echo "You will be prompted for a passphrase:"
    ssh-keygen -t ed25519 -C "niklas@$(hostname)-to-github" -f "$KEYFILE"
else
    echo "Key already exists: $KEYFILE"
fi

# --- Step 2: Copy / print public key ---
echo ""
echo "Add this public key to GitHub → https://github.com/settings/ssh/new"
echo ""

if command -v pbcopy >/dev/null; then
    pbcopy < "${KEYFILE}.pub"
    echo "✓ Public key copied to clipboard (macOS)."
elif command -v xclip >/dev/null; then
    xclip -sel clip < "${KEYFILE}.pub"
    echo "✓ Public key copied to clipboard (Linux)."
else
    cat "${KEYFILE}.pub"
fi

echo ""
read -rp "Press Enter after you've added the key to GitHub..."

# --- Step 3: Switch remote to SSH ---
cd "$REPO_DIR"
current_remote=$(git remote get-url origin 2>/dev/null || true)

if [[ "$current_remote" == "$SSH_REMOTE" ]]; then
    echo "Remote is already set to SSH."
else
    git remote set-url origin "$SSH_REMOTE"
    echo "✓ Remote switched to SSH: $SSH_REMOTE"
fi

# --- Verify ---
echo ""
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com 2>&1 || true
