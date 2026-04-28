---
layout: default
title: Updating
---

## When `git pull` is enough

If a change only modifies the **content** of tracked files (no files added, removed, or renamed), the symlinks stow created are still valid and the new content is live immediately — stow links point at the repo files directly.

```bash
cd ~/dotfiles && git pull
exec zsh   # reload shell if zsh files changed
```

## When you need to restow

Restow is required whenever the **set of managed files changes**:

| Situation | Example |
|---|---|
| File added to a package | new `conf.d/foo.zsh` |
| File removed from a package | deleted `aliases.zsh` |
| File renamed or moved | `aliases.zsh` → `conf.d/vpn.zsh` |
| New directory added inside a package | `conf.d/` |

After `git pull` in these cases you'll have **broken symlinks** in `~` or `~/.config/` pointing at files that no longer exist in the repo.

### Detect broken symlinks

```bash
find ~/.config -xtype l 2>/dev/null
find ~ -maxdepth 1 -xtype l 2>/dev/null
```

### Fix: restow the affected package

```bash
cd ~/dotfiles && stow -R <package>
```

`-R` (restow) removes every existing symlink for the package and re-creates them from the current repo state, cleaning up anything stale.

Common per-package commands:

```bash
stow -R zsh
stow -R ssh
stow -R git
stow -R nvim
stow -R claude
stow -R alacritty
stow -R aerospace
stow -R ciscosecureclient
```

Then reload the shell:

```bash
exec zsh
```

## How to tell which packages changed

```bash
git log --oneline origin/main..HEAD   # commits not yet pulled
git diff --name-only HEAD@{1} HEAD    # files changed since last pull
```

Files under `zsh/` → restow `zsh`. Files under `nvim/` → restow `nvim`. Etc.

## Reference: what stow manages per package

| Package | Stow target | Notable managed paths |
|---|---|---|
| `zsh` | `~` | `~/.zshenv`, `~/.config/zsh/` |
| `ssh` | `~` | `~/.config/ssh/` |
| `git` | `~` | `~/.gitconfig` |
| `nvim` | `~` | `~/.config/nvim/` |
| `claude` | `~` | `~/.claude/` |
| `alacritty` | `~` | `~/.config/alacritty/` |
| `aerospace` | `~` | `~/.config/aerospace/` |
| `ciscosecureclient` | `~` | `~/.vpn-creds.template` |
