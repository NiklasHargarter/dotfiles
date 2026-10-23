# dotfiles

My personal config for macOS (desktop) and Linux (headless servers). One repo,
one command to bring a new machine to a working state. Flat and symlink-based —
each top-level folder is a tool; an `install` script links its files to where
the tool expects them.

```
bash/  git/  ssh/  claude/  ghostty/  zellij/  nvim/  vpn/  scripts/
```

---

## Bootstrap a new machine

```bash
git clone https://github.com/niklashargarter/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh            # packages + symlinks + shell + claude
~/dotfiles/scripts/setup-ssh-keys.sh   # generate & deploy SSH keys
exec bash -l                           # reload shell
```

`setup.sh` is idempotent — safe to re-run any time. It installs packages
(brew on macOS, apt on Linux), symlinks every config into place, makes bash
the login shell, installs Claude Code, and switches the repo remote
from HTTPS to SSH at the end.

Clone over **HTTPS** first (no key needed yet); `setup.sh` flips the remote to
SSH once your GitHub key exists.

---

## The stack

| Area | Tool | Config |
|---|---|---|
| Shell | Bash — one file, no framework | `bash/bashrc` |
| Terminal | [Ghostty](https://ghostty.org) | `ghostty/config` |
| Multiplexer | [Zellij](https://zellij.dev) | `zellij/config.kdl` |
| Editor | [Neovim](https://neovim.io) — small hand-written Lua config | `nvim/` (docs in `nvim/README.md`) |
| AI CLI | [Claude Code](https://claude.com/claude-code) | `claude/` |
| VCS | Git | `git/gitconfig` |
| SSH | Modular, self-documenting config | `ssh/config` |
| VPN | [OpenConnect](https://www.infradead.org/openconnect/) (AnyConnect-compatible) | `vpn/creds.template` |

---

## How it works

**Symlinks, no stow.** `setup.sh` holds a plain map — repo file → system path:

```
bash/bashrc        → ~/.bashrc and ~/.bash_profile
claude/settings.json → ~/.claude/settings.json
ghostty/config     → ~/.config/ghostty/config
```

Files are named plainly in the repo (`gitconfig`, not `.gitconfig`) and the
map puts them where they belong. To see or change what links where, read the
`link …` block in `scripts/setup.sh`.

**One shell file.** `bash/bashrc` is linked as both `~/.bashrc` and
`~/.bash_profile`, so login (macOS, ssh) and non-login shells behave the same.
No framework, no plugins: completion comes from the `bash-completion` package,
history search and file picking from `fzf`. Everything updates with brew/apt.
Bash is also what project scripts run in (`#!/usr/bin/env bash`), so what you
type is what teammates get; check scripts with `shellcheck`.

---

## Daily usage

### Shell (`bash/bashrc`)

```
ll         eza long listing (git-aware)
v / g      nvim / git
gst gd gco gsw gl gp …  Oh My Zsh git aliases, tab-complete branches
cd         zoxide jump (cdi = fzf pick)
keys       every readline binding, fuzzy-searchable
focus      this week's FOCUS.md (focus -e to edit)
tools      what the installed CLI tools do (TOOLS.md)
```

| Keys | Action |
|---|---|
| `Ctrl-W` / `Alt-Backspace` | delete word back |
| `Ctrl-U` / `Ctrl-K` | delete to line start / end |
| `Ctrl-A` / `Ctrl-E`, `Alt-B` / `Alt-F` | line start / end, word back / forward |
| `Ctrl-Y` | paste last deleted text |
| `Ctrl-R` / `Ctrl-T` / `Alt-C` | fzf history / file / dir |
| `Tab` | complete (case-insensitive, lists on first press) |

### Zellij — persistent work sessions

Sessions live on the machine and survive disconnect. SSH into a workstation and
you're dropped straight back into your `main` session.

```
zj [name]   attach-or-create a session   (zj, zj build, zj scrape …)
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

- `claude/CLAUDE.md` → `~/.claude/CLAUDE.md`: global style rules (terse, minimal diffs).
  No plugins — current models don't need them; add back in `settings.json` if one earns it.
- Statusline shows repo · branch · git counts · context-window %:
  ```
  dotfiles | main | S:0 U:2 A:1 | ctx 24% · 48k/200k
  ```
  Computed locally from the session transcript (`claude/statusline-context.py`) —
  no network. Keep context under ~60% for best results.

Machine-independent:

- **Own skills** live in `claude/skills/`, dir-linked to `~/.claude/skills`. A new
  skill is live after `git pull`, no relink. Available in every project, not one repo.
  `claude/skills/synced/` is claude.ai's own sync target — gitignored.

A skill is one dir with a `SKILL.md` (frontmatter `name` + `description`; the
description is what makes Claude reach for it). Keep it generic — project specifics
belong in that project's `CLAUDE.md`, which the skill reads.

### VPN (OpenConnect)

Aliases load only if `openconnect` is installed. Connecting needs `sudo`.

```bash
cp vpn/creds.template ~/.vpn-creds && chmod 600 ~/.vpn-creds
# then edit ~/.vpn-creds — gitignored, never committed
```

`~/.vpn-creds`, one value per line:

```
your-vpn-gateway.com   # gateway host
YOUR_USERNAME
YOUR_PASSWORD
YOUR_GROUP             # auth group, as listed in the GROUP: prompt
```

If the gateway wants a client certificate ("Certificate Validation Failure"),
export it from the keychain to `~/.vpn-cert.pem` (cert + unencrypted key);
`vpnup` picks it up. macOS writes legacy RC2 PKCS#12, hence `-legacy`:

```bash
security export -t identities -f pkcs12 -P "" -o /tmp/vpn.p12
(umask 077; openssl pkcs12 -legacy -in /tmp/vpn.p12 -nodes -passin pass: -out ~/.vpn-cert.pem)
rm /tmp/vpn.p12
```

| Alias | Action |
|---|---|
| `vpnup` | connect in the background with saved creds |
| `vpndown` | disconnect |
| `vpnstat` | show the running connection |

---

## Updating an existing machine

```bash
cd ~/dotfiles && git pull && ./scripts/setup.sh && exec bash -l
```

That's the whole procedure — same on a box updated yesterday and one untouched
for a year. `setup.sh` is idempotent, sweeps dead links from old layouts before
relinking, and refuses to clobber a real file that's squatting a link target.
There's no separate migration path and no teardown step.

Content-only change in an already-linked file needs nothing but `git pull` —
symlinks point straight at the repo, so it's live immediately. Re-running
`setup.sh` anyway is free.

**Two things it can't do for you:**

- **A dirty tree blocks the pull.** Drift is live edits made *through* the
  symlinks. Check whether it's already upstream (`git diff`) — usually a subset
  → discard. Genuinely new? Lift it into the repo properly (`bash/bashrc`, a
  `link` line), don't leave it loose.
- **Links pointing *outside* the repo** (old vendored skills, hand-made links)
  are invisible to the sweep — it only tracks links *into* `~/dotfiles`. Sweep
  `~/.claude`, `~/.agents` by hand if an old setup put them there.

## Adding things

| Want | Do |
|---|---|
| New alias / shell tweak | edit `bash/bashrc` |
| New app config | drop the file in a folder, add a `link` line in `scripts/setup.sh`, re-run it |
| New Claude skill | `claude/skills/<name>/SKILL.md` — no `link` line, the dir is already linked |
| New SSH host | add a `Host` block + `# deploy:` marker to `ssh/config`, run `setup-ssh-keys.sh <host>` |
| Node on a dev box | not in the baseline (apt's is stale, Claude doesn't need it). Where you need it: **mac** `brew install node` · **linux** `curl -fsSL https://deb.nodesource.com/setup_lts.x \| sudo -E bash - && sudo apt-get install -y nodejs` |
| Machine-specific bits | `~/.bashrc.local` — sourced if present, not in the repo |

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
| Leftovers from the old zsh setup | `rm -rf ~/.oh-my-zsh ~/.config/zsh ~/.zsh_history ~/.zcompdump*` |
| Neovim state/data (keeps binary) | `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim` |
| Claude Code data ⚠ | `rm -rf ~/.claude` |
| brew/apt packages (shared) | uninstall only if unused elsewhere |

**Never remove without intent:** `~/.ssh/` keys, `~/.vpn-creds`,
`~/.bash_history`, the `~/dotfiles` repo.

**Or hand it to Claude** — paste this into Claude Code *on the target machine*
to wipe it before a clean reinstall:

```text
Wipe this machine's dotfiles footprint so I can re-run ~/dotfiles/scripts/setup.sh
from a clean state. Rules:
1. First run ~/dotfiles/scripts/teardown.sh (safe unlink) and show the output.
2. Read setup.sh, inventory what it installs, and check what's actually present
   here (packages, nvim data, ~/.claude, npm globals, caches).
3. Show a numbered removal plan grouped by risk. Do NOT run destructive commands
   (rm -rf, brew/apt uninstall, deleting ~/.claude) until I approve.
4. Never touch: ~/.ssh/ keys, ~/.vpn-creds, ~/.bash_history, ~/dotfiles.
5. Shared tooling (brew/apt, ~/.npm-global) — ask per item before removing.
6. After I approve, print the rebuild commands: setup.sh then setup-ssh-keys.sh.
```
