#!/usr/bin/env bash
# Minimal dotfiles setup for machines where you are NOT root — HPC login nodes,
# shared boxes, anything with no sudo. Installs nvim to ~/.local and links the
# config in minimal mode (no plugins, no LSP, no node, nothing to compile).
#
# What you get: nvim with your options + keymaps. That's it. ~50 MB, one curl.
# Want the full config on a box where it makes sense? Drop NVIM_MINIMAL from
# ~/.bashrc, open nvim once on a node with internet, let lazy do its thing.
#
#   --zsh   also install zsh (statically linked, no root) + Oh My Zsh + p10k
#           and your real zshrc. Costs ~5 git clones. Without it you stay on
#           bash with two aliases.
#
# Deliberately NOT here: zellij, claude, rust, git config, ssh config.
# Add a line if you find you actually miss one.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
WANT_ZSH=0
[[ "${1:-}" == "--zsh" ]] && WANT_ZSH=1

step() { echo ""; echo "==> $*"; }

# ── Neovim ────────────────────────────────────────────────────────────────────
# Official prebuilt tarball. Needs glibc 2.35+ (built on Ubuntu 22.04) — check
# with `ldd --version` if a new machine refuses to run it; on anything older
# grab neovim from conda-forge instead, it targets glibc 2.17.
step "Installing Neovim to ~/.local"
mkdir -p ~/.local/bin ~/.local/nvim
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    | tar -xz -C ~/.local/nvim --strip-components=1
ln -sfn ~/.local/nvim/bin/nvim ~/.local/bin/nvim
echo "    $(~/.local/bin/nvim --version | head -1)"

# ── Config ────────────────────────────────────────────────────────────────────
step "Linking nvim config"
if [[ -e ~/.config/nvim && ! -L ~/.config/nvim ]]; then
    echo "ERROR: ~/.config/nvim exists and is not a symlink. Move it, re-run." >&2
    exit 1
fi
mkdir -p ~/.config
ln -sfn "$DOTFILES/nvim" ~/.config/nvim
echo "    linked ~/.config/nvim"

# ── Shell ─────────────────────────────────────────────────────────────────────
# Appended to ~/.bashrc, not a symlink: the machine's own bashrc usually carries
# site setup (module init, scheduler env) that must keep working.
step "Wiring ~/.bashrc"
if ! grep -qF 'dotfiles:minimal' ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<'EOF'

# dotfiles:minimal — see scripts/setup-minimal.sh
export PATH="$HOME/.local/bin:$PATH"
export NVIM_MINIMAL=1
export EDITOR=nvim
alias v='nvim'
alias g='git'
EOF
    echo "    appended (marker: dotfiles:minimal)"
else
    echo "    [skip] already wired"
fi

# ── Zsh (opt-in) ──────────────────────────────────────────────────────────────
if (( WANT_ZSH )); then
    # romkatv/zsh-bin: a fully static zsh 5.8 + bundled terminfo, ~4 MB, no root
    # and no build deps. Same author as Powerlevel10k, so the pair is a tested
    # combination. `-d ~/.local` given once = non-interactive (more than one -d
    # opens a chooser dialog); `-e no` skips /etc/shells, which needs root anyway.
    step "Installing zsh (static, no root)"
    if [[ -x ~/.local/bin/zsh ]]; then
        echo "    [skip] already installed ($(~/.local/bin/zsh --version))"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install)" \
            -- -q -d ~/.local -e no
        echo "    $(~/.local/bin/zsh --version)"
    fi

    step "Installing Oh My Zsh + Powerlevel10k"
    if [[ ! -d ~/.oh-my-zsh ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "    [skip] oh-my-zsh already present"
    fi
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    for repo in \
        "romkatv/powerlevel10k themes/powerlevel10k" \
        "zsh-users/zsh-autosuggestions plugins/zsh-autosuggestions" \
        "zsh-users/zsh-completions plugins/zsh-completions" \
        "zsh-users/zsh-syntax-highlighting plugins/zsh-syntax-highlighting" \
        "Aloxaf/fzf-tab plugins/fzf-tab"
    do
        set -- $repo
        [[ -d "$ZSH_CUSTOM/$2" ]] || git clone --depth=1 "https://github.com/$1.git" "$ZSH_CUSTOM/$2"
    done
    # Prebuilt gitstatusd, so p10k doesn't prompt to download it on first prompt.
    "$ZSH_CUSTOM/themes/powerlevel10k/gitstatus/install" -f

    step "Linking zsh config"
    # OMZ's installer replaces a .zshrc symlink with a real file — link after it
    # runs, not before, and clear the backup it leaves behind.
    rm -f ~/.config/zsh/.zshrc ~/.config/zsh/.zshrc.pre-oh-my-zsh
    mkdir -p ~/.config/zsh/conf.d
    ln -sfn "$DOTFILES/zsh/zshenv"   ~/.zshenv
    ln -sfn "$DOTFILES/zsh/zshrc"    ~/.config/zsh/.zshrc
    ln -sfn "$DOTFILES/zsh/p10k.zsh" ~/.config/zsh/.p10k.zsh
    # Only the fragments that can do anything here. vpn/zellij are for machines
    # that have those tools; the rest self-guard on a missing binary.
    for f in aliases zoxide rust; do
        ln -sfn "$DOTFILES/zsh/$f.zsh" ~/.config/zsh/conf.d/"$f.zsh"
    done
    echo "    linked ~/.zshenv, ~/.config/zsh/"

    # No chsh without root, so bash hands off instead. Guards, in order: only an
    # interactive shell (scp/rsync/sbatch must never be hijacked), only when not
    # already in zsh, only when the binary really is executable, and NO_ZSH=1 as
    # an escape hatch. zsh does not read ~/.bashrc, so this cannot loop.
    step "Handing bash off to zsh"
    if ! grep -qF 'dotfiles:exec-zsh' ~/.bashrc 2>/dev/null; then
        cat >> ~/.bashrc <<'EOF'

# dotfiles:exec-zsh — no chsh without root. Escape hatch: NO_ZSH=1 ssh host
if [[ $- == *i* && -z "${ZSH_VERSION:-}" && -z "${NO_ZSH:-}" && -x "$HOME/.local/bin/zsh" ]]; then
    exec "$HOME/.local/bin/zsh" -l
fi
EOF
        echo "    appended (marker: dotfiles:exec-zsh)"
    else
        echo "    [skip] already wired"
    fi
fi

echo ""
echo "Done. Reload:  exec bash -l"
