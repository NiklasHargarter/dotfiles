#!/usr/bin/env bash
# Full non-interactive dotfiles setup.
# Safe to re-run — every step is idempotent.
set -euo pipefail

# Run as yourself, never with sudo: under sudo $HOME is /root, so every link
# below silently lands in root's home and this machine gets nothing.
if [[ "$EUID" -eq 0 ]]; then
    echo "ERROR: don't run this with sudo — it escalates on its own where needed." >&2
    echo "       Under sudo, \$HOME is $HOME, so the dotfiles would link into" >&2
    echo "       root's home instead of yours. Re-run as: ./scripts/setup.sh" >&2
    exit 1
fi

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"

step()  { echo ""; echo "==> $*"; }
info()  { echo "    $*"; }
skip()  { echo "    [skip] $*"; }

# link <repo-relative-src> <target> — flat repo path → dotted system path.
link() {
    local src="$DOTFILES/$1" dst="$2"
    # A real file/dir squatting the target is never harmless: ln -sfn would
    # delete a real file outright, and for a real dir it silently creates the
    # link *inside* it (dst/name -> src), so the config never loads and nothing
    # errors. Stop loudly and let the human decide what that file was.
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "ERROR: $dst exists and is not a symlink." >&2
        echo "       Move or delete it, then re-run this script." >&2
        exit 1
    fi
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
    brew install bash bash-completion@2 shellcheck eza ripgrep curl git fzf fd neovim node zellij bat jq btop zoxide tree-sitter ncdu gh
elif [[ "$OS" == "Linux" ]]; then
    sudo apt-get update -qq
    # nvim: python3-venv (mason PyPI pkgs, e.g. ruff), build-essential
    #       (treesitter + telescope-fzf-native compile from C)
    # Not from apt: neovim (0.9, too old for this config), nodejs (ancient) —
    # tarball + NodeSource below.
    sudo apt-get install -y bash-completion shellcheck eza ripgrep curl git fzf fd-find python3 python3-venv \
        bat jq btop zoxide ncdu gh build-essential

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

    # tree-sitter CLI — nvim-treesitter's `main` branch compiles every parser by
    # shelling out to `tree-sitter build`, a subcommand that only exists in CLI
    # 0.22+. Ubuntu ships `tree-sitter-cli` 0.20.8, which has only `build-wasm`,
    # so an apt copy on PATH fails every parser. Deliberately NOT guarded on
    # `command -v`: the failure mode is a *stale* binary being present, so a
    # presence check would skip exactly the machines that need this.
    curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
        | gunzip > ~/.local/bin/tree-sitter
    chmod +x ~/.local/bin/tree-sitter
fi

# ── 1b. Rust toolchain ──────────────────────────────────────────────────────────
# rustup gives rustc/cargo/rustfmt (fixes nvim's Rust LSP + format-on-save, and
# is the "annoying when missing" toolchain). --no-modify-path so it never edits
# the symlinked ~/.bashrc; bash/bashrc puts ~/.cargo/bin on PATH instead.
step "Installing Rust toolchain (rustup)"
if ! command -v rustup >/dev/null && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
else
    skip "rustup already installed"
fi

# ── 1c. Sweep stale links ──────────────────────────────────────────────────────
# A rework that moves or deletes a repo file leaves a dead symlink behind on
# every machine set up under the old layout. Broken + points into ~/dotfiles =
# ours and obsolete, so clear it here. This is why `git pull && setup.sh` is the
# whole update procedure — no separate teardown ritual for a drifted machine.
# Scope matches teardown.sh: shallow on ~, deeper only in the two config trees,
# so we never walk node_modules or ~/.claude/projects.
step "Sweeping stale links from past reworks"
{ find ~ -maxdepth 1 -xtype l
  find ~/.config ~/.claude -maxdepth 3 -xtype l 2>/dev/null || true
} | while IFS= read -r f; do
    case "$(readlink "$f")" in
        *dotfiles/*) rm "$f" && info "removed dead ${f/#$HOME/\~}" ;;
    esac
done

# ── 2. Symlink config into place ────────────────────────────────────────────────
step "Linking dotfiles"
chmod 700 ~/.ssh 2>/dev/null || { mkdir -p ~/.ssh && chmod 700 ~/.ssh; }

# Distros ship a real ~/.bashrc (and sometimes ~/.bash_profile); keep it aside
# once instead of having link() refuse. Anything worth keeping → ~/.bashrc.local
for f in ~/.bashrc ~/.bash_profile; do
    if [[ -f "$f" && ! -L "$f" ]]; then
        mv "$f" "$f.pre-dotfiles" && info "moved ${f/#$HOME/\~} → ${f/#$HOME/\~}.pre-dotfiles"
    fi
done
link bash/bashrc                  ~/.bashrc
link bash/bashrc                  ~/.bash_profile
link git/gitconfig                ~/.gitconfig
link ssh/config                   ~/.config/ssh/config
link claude/settings.json         ~/.claude/settings.json
link claude/CLAUDE.md             ~/.claude/CLAUDE.md
link claude/skills                ~/.claude/skills
link claude/statusline-command.sh ~/.claude/statusline-command.sh
link claude/statusline-context.py ~/.claude/statusline-context.py
link claude/statusline-wrapper.sh ~/.claude/statusline-wrapper.sh
link ghostty/config               ~/.config/ghostty/config
link zellij/config.kdl            ~/.config/zellij/config.kdl
link nvim                         ~/.config/nvim
# vpn/creds.template is a template, filled manually.

# ── 3. Default shell ───────────────────────────────────────────────────────────
# macOS: brew's bash, not /bin/bash (3.2 from 2007). Linux: the system one.
step "Setting bash as default shell"
if [[ "$OS" == "Darwin" ]]; then BASH_PATH="$(brew --prefix)/bin/bash"; else BASH_PATH=/bin/bash; fi
if [[ "$SHELL" != "$BASH_PATH" ]]; then
    grep -qxF "$BASH_PATH" /etc/shells || echo "$BASH_PATH" | sudo tee -a /etc/shells
    chsh -s "$BASH_PATH"
    info "Default shell → $BASH_PATH"
else
    skip "already using $BASH_PATH"
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

# ── 5. Claude Code ────────────────────────────────────────────────────────────
step "Installing Claude Code"
# Already there = leave it alone; Claude Code self-updates on launch, so
# re-running the installer only re-downloads what it would fetch anyway.
if command -v claude >/dev/null; then
    skip "already installed ($(claude --version))"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

# ── 6. Switch dotfiles remote to SSH ──────────────────────────────────────────
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
echo "  1. Reload shell       exec bash -l"
echo "  2. SSH keys           ./scripts/setup-ssh-keys.sh"
echo "  3. VPN credentials    cp vpn/creds.template ~/.vpn-creds && chmod 600 ~/.vpn-creds"
echo "                        (then edit ~/.vpn-creds with your real values)"
