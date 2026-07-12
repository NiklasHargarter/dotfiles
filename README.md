# dotfiles

My personal config for macOS (desktop) and Linux (headless servers). One repo,
one command to bring a new machine to a working state. Flat and symlink-based —
each top-level folder is a tool; an `install` script links its files to where
the tool expects them.

```
zsh/  git/  ssh/  claude/  ghostty/  vpn/  scripts/
```

---

## Bootstrap a new machine

```bash
git clone https://github.com/niklashargarter/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh            # packages + symlinks + zsh + claude
~/dotfiles/scripts/setup-ssh-keys.sh   # generate & deploy SSH keys
exec zsh                               # reload shell
```

`setup.sh` is idempotent — safe to re-run any time. It installs packages
(brew on macOS, apt on Linux), symlinks every config into place, sets up
Oh My Zsh + Powerlevel10k, installs Claude Code, and switches the repo remote
from HTTPS to SSH at the end.

Clone over **HTTPS** first (no key needed yet); `setup.sh` flips the remote to
SSH once your GitHub key exists.

---

## The stack

| Area | Tool | Config |
|---|---|---|
| Shell | Zsh + Oh My Zsh + Powerlevel10k | `zsh/` |
| Terminal (mac) | [Ghostty](https://ghostty.org) | `ghostty/config` |
| Multiplexer | [Zellij](https://zellij.dev) | `zsh/zellij.zsh` |
| Editor | Neovim (stock — no plugin config) | installed, not configured |
| AI CLI | [Claude Code](https://claude.com/claude-code) + caveman + ponytail | `claude/` |
| VCS | Git | `git/gitconfig` |
| SSH | Modular, self-documenting config | `ssh/config` |
| VPN | Cisco Secure Client | `vpn/creds.template` |

---

## How it works

**Symlinks, no stow.** `setup.sh` holds a plain map — repo file → system path:

```
zsh/zshrc          → ~/.config/zsh/.zshrc
zsh/aliases.zsh    → ~/.config/zsh/conf.d/aliases.zsh
claude/settings.json → ~/.claude/settings.json
ghostty/config     → ~/.config/ghostty/config   (macOS only)
```

Files are named plainly in the repo (`zshrc`, not `.config/zsh/.zshrc`) and the
map puts them where they belong. To see or change what links where, read the
`link …` block in `scripts/setup.sh`.

**Modular zsh.** `.zshrc` auto-sources every `*.zsh` in `~/.config/zsh/conf.d/`.
Each fragment guards its own dependency, so it's safe on any machine:

```zsh
# zsh/zellij.zsh
command -v zellij >/dev/null || return   # no-op if zellij absent
```

---

## Daily usage

### Aliases (`zsh/aliases.zsh`)

```
dot        cd ~/dotfiles
dots       git status of the dotfiles repo
dotpull    pull dotfiles
ll         eza long listing (git-aware)
v / g      nvim / git
```

Add your own by editing `zsh/aliases.zsh` — it's already linked and auto-sourced.

### Zellij — persistent work sessions

Sessions live on the machine and survive disconnect. SSH into a workstation and
you're dropped straight back into your `main` session.

```
zj [name]   attach-or-create a session   (zj, zj build, zj scrape …)
zjp         fzf-pick a running session
zwork zproj shortcuts for zj work / zj project
zl          list sessions
```

Auto-resume: an **interactive SSH login auto-attaches** to `main`. Local shells,
scp, and scripts are untouched. Bypass with `NO_ZELLIJ=1 ssh host`.

Inside a session:

| Keys | Action |
|---|---|
| `Ctrl+o d` | **detach** — leaves the session running on the box |
| `Ctrl+o w` | session manager — switch / create / rename |
| `Ctrl+p` / `Ctrl+t` / `Ctrl+n` | pane / tab / resize modes |

Rule of thumb: **detach (`Ctrl+o d`), never `exit`**, on sessions you want to
keep alive. One session per task; the machine already isolates your work.

### SSH keys

`ssh/config` is the single source of truth. Each managed host has a
`# deploy: server|manual` marker above it and an `IdentityFile`:

```sshconfig
# deploy: server
Host slifer
    HostName 193.175.188.174
    User niklas
    IdentityFile ~/.ssh/id_ed25519_slifer
```

```bash
./scripts/setup-ssh-keys.sh           # every annotated host
./scripts/setup-ssh-keys.sh slifer    # just one
```

- `server` — generates the key and `ssh-copy-id`s it to the host (you have
  password/SSH access already).
- `manual` — generates the key and copies the pubkey to your clipboard to paste
  into a web UI:

  | Service | Paste at |
  |---|---|
  | GitHub | `github.com/settings/ssh/new` |
  | GitLab | `<host>/-/user_settings/ssh_keys` |
  | Forgejo / Gitea | `<host>/user/settings/keys` |

Idempotent — existing keys are reused. Keys are per-machine and never committed
(`*.key`/`*.pem` gitignored). Deployed server keys must be removed manually from
each host's `~/.ssh/authorized_keys`.

### Ghostty over SSH

Ghostty uses `TERM=xterm-ghostty`, which remote machines don't recognize
(garbled keys/colors). The config enables Ghostty's own fix:

```
shell-integration-features = cursor,title,ssh-env,ssh-terminfo
```

`ssh-terminfo` installs Ghostty's terminfo on machines you control; `ssh-env`
falls back to `xterm-256color` on machines you don't. Nothing to run per host.

### Claude Code

- `caveman` — compressed, no-fluff text output.
- `ponytail` — laziest-that-works coding.
- Statusline shows repo · branch · git counts · context-window %:
  ```
  dotfiles | main | S:0 U:2 A:1 | ctx 24% · 48k/200k
  ```
  Computed locally from the session transcript (`claude/statusline-context.py`) —
  no network. Keep context under ~60% for best results.

Plugins auto-install on first launch from `claude/settings.json`.

### VPN (Cisco Secure Client)

Aliases load only if the Cisco binary exists (`/opt/cisco/{secureclient,anyconnect}/bin/vpn`).

```bash
cp vpn/creds.template ~/.vpn-creds && chmod 600 ~/.vpn-creds
# then edit ~/.vpn-creds — gitignored, never committed
```

`~/.vpn-creds` is fed to the client line by line:

```
connect your-vpn-gateway.com   # gateway host
0                              # profile index (first)
YOUR_USERNAME
YOUR_PASSWORD
y                              # accept banner
```

| Alias | Action |
|---|---|
| `vpnup` | connect with saved creds |
| `vpndown` | disconnect |
| `vpnstat` | connection stats |

---

## Updating an existing machine

```bash
dotpull        # git -C ~/dotfiles pull
exec zsh       # if shell config changed
```

- **Content changed** in a tracked file → `git pull` is enough; symlinks point
  straight at the repo, so it's live immediately.
- **Files added / removed / renamed** → re-run `~/dotfiles/scripts/setup.sh` to
  refresh the links. Find stragglers with:
  ```bash
  find ~/.config ~/.claude -xtype l 2>/dev/null   # broken symlinks
  ```

## Adding things

| Want | Do |
|---|---|
| New alias / shell tweak | edit `zsh/aliases.zsh` (or add `zsh/<tool>.zsh` with a guard) |
| New app config | drop the file in a folder, add a `link` line in `scripts/setup.sh`, re-run it |
| New SSH host | add a `Host` block + `# deploy:` marker to `ssh/config`, run `setup-ssh-keys.sh <host>` |
| Machine-specific bits | `~/.config/zsh/conf.d/local.zsh` — auto-sourced, gitignored |

## Teardown

There's no universal full-teardown — every machine has a different pile of
installed tooling. So it's split: a safe unlink script, plus a per-machine menu.

**Safe reset (always fine):**

```bash
DRY_RUN=1 ~/dotfiles/scripts/teardown.sh   # preview — changes nothing
~/dotfiles/scripts/teardown.sh             # do it
```

Removes only symlinks pointing into `~/dotfiles` — no packages, no app data.
It **discovers** them (scans `~`, `~/.config`, `~/.claude`) rather than working
from a fixed list, so it also clears **stale links left by old reworks** on a
machine that drifted from the current repo — dead links included. Your repo, SSH
keys, shell history, and `~/.vpn-creds` are left alone.

**Per-machine cleanup** — pick only what applies; none of it is needed to re-run
`setup.sh`:

| What | Command |
|---|---|
| Oh My Zsh + theme + plugins | `rm -rf ~/.oh-my-zsh` |
| Neovim state/data (keeps binary) | `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim` |
| Claude Code data ⚠ | `rm -rf ~/.claude` |
| brew/apt packages (shared) | uninstall only if unused elsewhere |

**Never remove without intent:** `~/.ssh/` keys, `~/.vpn-creds`,
`~/.zsh_history`, the `~/dotfiles` repo.

**Or hand it to Claude** — paste this into Claude Code *on the target machine*
to wipe it before a clean reinstall:

```text
Wipe this machine's dotfiles footprint so I can re-run ~/dotfiles/scripts/setup.sh
from a clean state. Rules:
1. First run ~/dotfiles/scripts/teardown.sh (safe unlink) and show the output.
2. Read setup.sh, inventory what it installs, and check what's actually present
   here (packages, ~/.oh-my-zsh, nvim data, ~/.claude, npm globals, caches).
3. Show a numbered removal plan grouped by risk. Do NOT run destructive commands
   (rm -rf, brew/apt uninstall, deleting ~/.claude) until I approve.
4. Never touch: ~/.ssh/ keys, ~/.vpn-creds, ~/.zsh_history, ~/dotfiles.
5. Shared tooling (brew/apt, ~/.npm-global) — ask per item before removing.
6. After I approve, print the rebuild commands: setup.sh then setup-ssh-keys.sh.
```
