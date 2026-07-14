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

# link <repo-relative-src> <target> — flat repo path → dotted system path.
link() {
    local src="$DOTFILES/$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    info "linked ${dst/#$HOME/\~}"
}

# ── 1. System packages ─────────────────────────────────────────────────────────
step "Installing system packages"
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "ERROR: Homebrew not found. Install it first: https://brew.sh" >&2
        exit 1
    fi
    brew install zsh eza ripgrep curl git fzf fd neovim node zellij bat jq btop zoxide
elif [[ "$OS" == "Linux" ]]; then
    sudo apt-get update -qq
    # No apt `neovim` (0.9, too old for this config's LSP API) — tarball below.
    # No apt `nodejs`/`npm` either (ancient) — NodeSource LTS below. mason's LSP
    # servers are npm packages, so a modern node is required, not optional.
    # build-essential gives treesitter + telescope-fzf-native a C compiler.
    sudo apt-get install -y zsh eza ripgrep curl git fzf fd-find python3 \
        bat jq btop zoxide build-essential

    # Modern Node LTS via NodeSource (apt-managed, stays current on upgrade)
    if ! command -v node >/dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        skip "node already installed ($(node --version))"
    fi

    if ! command -v zellij >/dev/null; then
        mkdir -p ~/.local/bin
        curl -fsSLo /tmp/zellij.tar.gz https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
        tar -xf /tmp/zellij.tar.gz -C /tmp zellij
        mv /tmp/zellij ~/.local/bin/
        rm /tmp/zellij.tar.gz
    else
        skip "zellij already installed"
    fi

    # Latest Neovim from the official prebuilt tarball (apt's is years behind).
    mkdir -p ~/.local/bin
    curl -fsSLo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    rm -rf ~/.local/nvim && mkdir -p ~/.local/nvim
    tar -xf /tmp/nvim.tar.gz -C ~/.local/nvim --strip-components=1
    ln -sfn ~/.local/nvim/bin/nvim ~/.local/bin/nvim
    rm /tmp/nvim.tar.gz
fi

# ── 1b. Rust toolchain ──────────────────────────────────────────────────────────
# rustup gives rustc/cargo/rustfmt (fixes nvim's Rust LSP + format-on-save, and
# is the "annoying when missing" toolchain). --no-modify-path so it never edits
# the symlinked ~/.zshenv; zsh/rust.zsh puts ~/.cargo/bin on PATH instead.
step "Installing Rust toolchain (rustup)"
if ! command -v rustup >/dev/null && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
else
    skip "rustup already installed"
fi

# ── 2. Symlink config into place ────────────────────────────────────────────────
step "Linking dotfiles"
chmod 700 ~/.ssh 2>/dev/null || { mkdir -p ~/.ssh && chmod 700 ~/.ssh; }

link zsh/zshenv                   ~/.zshenv
link zsh/zshrc                    ~/.config/zsh/.zshrc
link zsh/p10k.zsh                 ~/.config/zsh/.p10k.zsh
link zsh/aliases.zsh              ~/.config/zsh/conf.d/aliases.zsh
link zsh/vpn.zsh                  ~/.config/zsh/conf.d/vpn.zsh
link zsh/zellij.zsh               ~/.config/zsh/conf.d/zellij.zsh
link zsh/zoxide.zsh               ~/.config/zsh/conf.d/zoxide.zsh
link zsh/rust.zsh                 ~/.config/zsh/conf.d/rust.zsh
link git/gitconfig                ~/.gitconfig
link ssh/config                   ~/.config/ssh/config
link claude/settings.json         ~/.claude/settings.json
link claude/statusline-command.sh ~/.claude/statusline-command.sh
link claude/statusline-context.py ~/.claude/statusline-context.py
link claude/statusline-wrapper.sh ~/.claude/statusline-wrapper.sh
link claude/link-vendor-skills.sh ~/.claude/scripts/link-vendor-skills.sh
link ghostty/config               ~/.config/ghostty/config
link nvim                         ~/.config/nvim
# vpn/creds.template is a template, filled manually.

# ── 3. Default shell ───────────────────────────────────────────────────────────
step "Setting zsh as default shell"
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    grep -qF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
    info "Default shell → $ZSH_PATH"
else
    skip "already using zsh"
fi

# ── 4. SSH include line ────────────────────────────────────────────────────────
step "Configuring SSH"
SSH_CONF=~/.ssh/config
touch "$SSH_CONF" && chmod 600 "$SSH_CONF"
if ! grep -qF "Include ~/.config/ssh/config" "$SSH_CONF"; then
    printf 'Include ~/.config/ssh/config\n\n' | cat - "$SSH_CONF" > "${SSH_CONF}.tmp"
    mv "${SSH_CONF}.tmp" "$SSH_CONF" && chmod 600 "$SSH_CONF"
    info "Include line added to ~/.ssh/config"
else
    skip "Include line already present"
fi

# ── 5. Oh My Zsh ──────────────────────────────────────────────────────────────
step "Installing Oh My Zsh"
if [[ ! -d ~/.oh-my-zsh ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    skip "already installed"
fi

# OMZ installer replaces the .zshrc symlink with a real file (+ a .pre-oh-my-zsh
# backup) — restore our symlink so the dotfiles version wins
rm -f ~/.config/zsh/.zshrc ~/.config/zsh/.zshrc.pre-oh-my-zsh
link zsh/zshrc ~/.config/zsh/.zshrc
info "Restored .zshrc symlink"

# ── 6. Powerlevel10k + plugins ────────────────────────────────────────────────
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

# ── 7. Claude Code ────────────────────────────────────────────────────────────
step "Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash
info "Plugins (caveman, ponytail, …) auto-install on first launch from settings.json"

# ── 8. Switch dotfiles remote to SSH ──────────────────────────────────────────
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
echo "  3. VPN credentials    cp vpn/creds.template ~/.vpn-creds && chmod 600 ~/.vpn-creds"
echo "                        (then edit ~/.vpn-creds with your real values)"
