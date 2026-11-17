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
    info "linked ~${dst#"$HOME"}"
}

# ── 1. System packages ─────────────────────────────────────────────────────────
step "Installing system packages"
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "ERROR: Homebrew not found. Install it first: https://brew.sh" >&2
        exit 1
    fi
    brew install bash shellcheck eza ripgrep curl git fzf fd neovim node zellij bat jq btop zoxide tree-sitter ncdu gh openconnect
elif [[ "$OS" == "Linux" ]]; then
    # Headless boxes: shell + CLI basics only. nvim and openconnect are mac-only.
    pkgs=(zsh shellcheck eza ripgrep curl git fzf fd-find python3
        bat jq btop zoxide ncdu gh)
    # Only touch sudo when something is missing, so updates run without a TTY.
    if ! dpkg -s "${pkgs[@]}" >/dev/null 2>&1; then
        sudo apt-get update -qq
        sudo apt-get install -y "${pkgs[@]}"
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
fi

# ── 1b. Sweep stale links ──────────────────────────────────────────────────────
# A rework that moves or deletes a repo file leaves a dead symlink behind on
# every machine set up under the old layout. Broken + points into ~/dotfiles =
# ours and obsolete, so clear it here. This is why `git pull && setup.sh` is the
# whole update procedure — no separate teardown ritual for a drifted machine.
# Scope matches teardown.sh: shallow on ~, deeper only in the two config trees,
# so we never walk node_modules or ~/.claude/projects.
step "Sweeping stale links from past reworks"
# -type l + [[ -e ]], not -xtype: macOS's BSD find has no -xtype.
{ find ~ -maxdepth 1 -type l
  find ~/.config ~/.claude -maxdepth 3 -type l 2>/dev/null || true
} | while IFS= read -r f; do
    [[ -e "$f" ]] && continue
    case "$(readlink "$f")" in
        *dotfiles/*) rm "$f" && info "removed dead ~${f#"$HOME"}" ;;
    esac
done

# ── 2. Symlink config into place ────────────────────────────────────────────────
step "Linking dotfiles"
chmod 700 ~/.ssh 2>/dev/null || { mkdir -p ~/.ssh && chmod 700 ~/.ssh; }

# A real ~/.zshrc or ~/.zshenv may exist already; keep it aside once instead of
# having link() refuse. Anything worth keeping → ~/.zshrc.local
for f in ~/.zshrc ~/.zshenv; do
    if [[ -f "$f" && ! -L "$f" ]]; then
        mv "$f" "$f.pre-dotfiles" && info "moved ~${f#"$HOME"} → ~${f#"$HOME"}.pre-dotfiles"
    fi
done
link zsh/zshrc                    ~/.zshrc
link zsh/zshenv                   ~/.zshenv
link zsh/p10k.zsh                 ~/.p10k.zsh
link git/gitconfig                ~/.gitconfig
link ssh/config                   ~/.config/ssh/config
link claude/settings.json         ~/.claude/settings.json
link claude/statusline-command.sh ~/.claude/statusline-command.sh
link claude/statusline-context.py ~/.claude/statusline-context.py
link claude/statusline-wrapper.sh ~/.claude/statusline-wrapper.sh
link ghostty/config               ~/.config/ghostty/config
link zellij/config.kdl            ~/.config/zellij/config.kdl
link nvim                         ~/.config/nvim
# vpn/creds.template is a template, filled manually.

# ── 3. Oh My Zsh + plugins ─────────────────────────────────────────────────────
# Plain clones rather than OMZ's installer, which fights the ~/.zshrc symlink.
# Re-running setup.sh updates them all.
step "Installing Oh My Zsh and plugins"
sync() {
    if [[ -d "$2" ]]; then git -C "$2" pull -q --ff-only
    else git clone -q --depth 1 "https://github.com/$1.git" "$2"; fi
    info "$1"
}
sync ohmyzsh/ohmyzsh ~/.oh-my-zsh
sync romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
for repo in Aloxaf/fzf-tab zsh-users/zsh-autosuggestions zsh-users/zsh-completions zsh-users/zsh-syntax-highlighting; do
    sync "$repo" ~/.oh-my-zsh/custom/plugins/"${repo#*/}"
done
# Pre-install gitstatus so p10k doesn't download it on first shell open.
~/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install -f

# ── 4. Default shell ───────────────────────────────────────────────────────────
# /bin/zsh is on macOS and Debian alike, and already in /etc/shells.
step "Setting zsh as default shell"
if [[ "$SHELL" != /bin/zsh ]]; then
    # chsh wants a password and hangs without a TTY, e.g. under an agent.
    if [[ -t 0 ]]; then chsh -s /bin/zsh; else info "no TTY — run: chsh -s /bin/zsh"; fi
else
    skip "already using /bin/zsh"
fi

# ── 5. SSH include line ────────────────────────────────────────────────────────
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

# ── 6. Dotfiles remote ────────────────────────────────────────────────────────
# Fetch over HTTPS, push over SSH: the repo is public and keys have a passphrase,
# so agents can pull with no key and only a push needs the human.
step "Setting dotfiles remote URLs"
git -C "$DOTFILES" remote set-url origin https://github.com/niklashargarter/dotfiles.git
git -C "$DOTFILES" remote set-url --push origin git@github.com:niklashargarter/dotfiles.git

# ── 7. VPN daemon (macOS) ──────────────────────────────────────────────────────
# Root runs a root-owned copy, not the repo file, so nothing user-writable runs
# as root. sudo only when the installed copy or plist is out of date.
if [[ "$OS" == "Darwin" ]]; then
    step "Installing VPN daemon"
    VPND=/usr/local/libexec/vpnd PLIST=/Library/LaunchDaemons/local.vpnd.plist
    want="$(sed "s|@HOME@|$HOME|" "$DOTFILES/vpn/vpnd.plist")"
    if cmp -s "$DOTFILES/vpn/vpnd" "$VPND" && [[ "$(cat "$PLIST" 2>/dev/null)" == "$want" ]]; then
        skip "up to date"
    elif [[ -t 0 ]]; then
        sudo install -d /usr/local/libexec
        sudo install -m 755 -o root -g wheel "$DOTFILES/vpn/vpnd" "$VPND"
        printf '%s\n' "$want" | sudo tee "$PLIST" >/dev/null
        sudo launchctl bootout system "$PLIST" 2>/dev/null || true
        sudo launchctl bootstrap system "$PLIST"
        info "installed and (re)started"
    else
        info "needs sudo — run ./scripts/setup.sh in a terminal"
    fi
fi

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "=============================="
echo " Setup complete"
echo "=============================="
echo ""
echo "Next: secrets and SSH keys. Run \`claude\` in ~/dotfiles and say"
echo "\"Set up this machine.\" bootstrap.sh does this for you."
